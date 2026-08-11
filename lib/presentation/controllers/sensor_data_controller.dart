import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/core/usecases/ble_advertisement_decoder.dart';
import 'package:survey_frontend/core/usecases/send_location_data_usecase.dart';
import 'package:survey_frontend/core/usecases/send_sensors_data_usecase.dart';
import 'package:survey_frontend/core/usecases/sensor_assignment_planner.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/core/usecases/sensor_connection_factory.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class SensorDataController extends ControllerBase {
  final RxList<SensorSlot> slots = <SensorSlot>[].obs;
  final RxBool noSensorConfigured = false.obs;
  final RxMap<String, SensorReading> sensorResponses =
      <String, SensorReading>{}.obs;
  final RxList<SensorDataValue> sensorValues = <SensorDataValue>[].obs;
  final RxBool isSendingData = false.obs;
  final SensorConnectionFactory _sensorConnectionFactory;
  final SendSensorsDataUsecase _sendSensorsDataUsecase;
  final SendLocationDataUsecase _sendLocationDataUsecase;
  final SensorAssignmentPlanner _planner;
  bool disconnected = false;
  bool _scanningAll = false;

  SensorDataController(this._sensorConnectionFactory,
      this._sendSensorsDataUsecase, this._sendLocationDataUsecase,
      this._planner);

  /// Populates the slot list (one per enabled Bluetooth-using assignment) in the idle state,
  /// without touching Bluetooth at all — called when the screen opens so the user sees what's
  /// assigned and can choose to connect, rather than the app connecting on their behalf.
  void prepareSlots() {
    disconnect();
    disconnected = false;

    final setup = _planner.readSetup();
    final assignments = _planner
        .orderedAssignments(setup)
        .where((assignment) => SensorKind.usesBluetooth(assignment.sensorTypeCode))
        .toList();

    if (assignments.isEmpty) {
      slots.clear();
      noSensorConfigured.value = true;
      return;
    }
    noSensorConfigured.value = false;
    slots.assignAll(assignments.map((assignment) => SensorSlot(
        sensorTypeCode: assignment.sensorTypeCode,
        displayName: _displayNameFor(setup, assignment.sensorTypeCode))));
  }

  /// Attempts every prepared slot's assignment concurrently, user-triggered — [SensorConnectionFactory]
  /// only serializes attempts that target the *same* sensor type, so unrelated sensor types
  /// connect in parallel instead of summing their timeouts.
  void startScanning() async {
    if (_scanningAll || slots.isEmpty) {
      return;
    }
    _scanningAll = true;
    try {
      final setup = _planner.readSetup();
      final assignments = _planner
          .orderedAssignments(setup)
          .where((assignment) => SensorKind.usesBluetooth(assignment.sensorTypeCode))
          .toList();
      if (assignments.length != slots.length) {
        // Stale relative to the current setup (e.g. assignments changed since the slots were
        // prepared) — re-prepare instead of attempting a mismatched pairing.
        prepareSlots();
        return;
      }

      await Future.wait([
        for (var index = 0; index < assignments.length; index++)
          _attemptSlot(slots[index], assignments[index], setup),
      ]);
    } finally {
      // Guaranteed even if something above throws unexpectedly — otherwise this flag gets stuck
      // `true` forever and every retry tap silently no-ops (retrySlot bails out on it below).
      _scanningAll = false;
    }
  }

  /// Re-attempts a single sensor without disturbing the others' connections/readings. Guards
  /// only against retrying *this* slot twice at once — [_scanningAll] is reserved for the
  /// all-sensors batch in [startScanning], so retrying one sensor never blocks retrying another;
  /// if both happen to target the same sensor *type*, [SensorConnectionFactory]'s own per-type
  /// lock catches that and surfaces it as [SensorSlotStatus.busy].
  void retrySlot(SensorSlot slot) async {
    if (disconnected || slot.status.value == SensorSlotStatus.scanning) {
      return;
    }
    final setup = _planner.readSetup();
    final assignment = _planner
        .orderedAssignments(setup)
        .where((candidate) => candidate.sensorTypeCode == slot.sensorTypeCode)
        .firstOrNull;
    if (assignment == null) {
      return;
    }
    await _attemptSlot(slot, assignment, setup);
  }

  /// Connects, takes exactly one reading, and disposes the connection immediately — no persistent
  /// connection, no periodic re-read. A held-open GATT connection has no benefit here (the value
  /// doesn't change fast enough to justify it) and this phone's BLE radio can't reliably keep a
  /// GATT link alive while a concurrent scan (e.g. another sensor's discovery) is running, so
  /// minimizing how long any connection stays open also avoids that instability.
  Future<void> _attemptSlot(SensorSlot slot,
      RespondentSensorAssignment assignment, MobileSensorSetup? setup) async {
    final timeout = _planner.timeoutFor(setup, assignment);
    slot.status.value = SensorSlotStatus.scanning;
    slot.secondsRemaining.value = timeout.inSeconds;
    final countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (slot.secondsRemaining.value > 0) {
        slot.secondsRemaining.value--;
      }
    });
    SensorConnection? connection;
    try {
      connection = await _sensorConnectionFactory.getSensorConnection(
        timeout,
        sensorTypeCode: assignment.sensorTypeCode,
        sensorId: assignment.sensorId,
        sensorMac: assignment.sensorMac,
      );
      if (disconnected) {
        return;
      }
      slot.status.value = SensorSlotStatus.found;
      final reading = await connection.getSensorData();
      if (disconnected) {
        return;
      }
      sensorResponses[assignment.sensorTypeCode] = reading;
      slot.values.assignAll(_sendSensorsDataUsecase.valuesFromResponse(reading));
      _recomputeSensorValues();
    } on BluetoothTurnedOffException {
      slot.status.value = SensorSlotStatus.bluetoothOff;
    } on SensorConnectionBusyException {
      // The background sync task (or another in-flight attempt) is already talking to this same
      // sensor type — not a real failure, just contention. Distinguish it from a hard error so
      // the user knows a quick retry is likely to succeed rather than something being broken.
      slot.status.value = SensorSlotStatus.busy;
    } on SensorNotFoundException {
      slot.status.value = SensorSlotStatus.notFound;
    } on AdvertisementPacketException {
      // The advertisement transport's equivalent of SensorNotFoundException: no matching,
      // decodable broadcast turned up in time — not a real error, just out of range/not seen yet.
      slot.status.value = SensorSlotStatus.notFound;
    } catch (e) {
      debugPrint('Sensor slot ${assignment.sensorTypeCode} failed: $e');
      Sentry.captureException(e);
      slot.errorMessage.value = _describeError(e);
      slot.status.value = SensorSlotStatus.error;
    } finally {
      countdown.cancel();
      await connection?.dispose();
    }
  }

  /// Translates a raw exception into something more actionable than a bare "Error" — most of the
  /// specific, expected failure shapes already get their own [SensorSlotStatus] (busy/not
  /// found/Bluetooth off), so what reaches here is either a genuine profile misconfiguration or an
  /// otherwise-unclassified connection drop.
  String _describeError(Object e) {
    final localizations = AppLocalizations.of(Get.context!)!;
    if (e is GattServiceNotFoundException || e is GattCharacteristicNotFoundException) {
      return localizations.sensorProfileMismatch;
    }
    return localizations.sensorConnectionLost;
  }

  String _displayNameFor(MobileSensorSetup? setup, String sensorTypeCode) {
    final type = setup?.sensorTypes
        .where((candidate) => candidate.sensorTypeCode == sensorTypeCode)
        .firstOrNull;
    return type?.sensorTypeName ?? sensorTypeCode;
  }

  void _recomputeSensorValues() {
    sensorValues.assignAll(sensorResponses.values.expand(
        (reading) => _sendSensorsDataUsecase.valuesFromResponse(reading)));
  }

  void disconnect() {
    disconnected = true;
    sensorResponses.clear();
    sensorValues.clear();
    slots.clear();
  }

  Future<void> sendSensorData() async {
    if (isSendingData.value || sensorResponses.isEmpty) {
      return;
    }

    if (sensorValues.isEmpty) {
      await popup(AppLocalizations.of(Get.context!)!.error,
          AppLocalizations.of(Get.context!)!.sensorReadingCannotBeStored);
      return;
    }

    try {
      isSendingData.value = true;
      var anySent = false;
      for (final reading in sensorResponses.values) {
        if (await _sendSensorsDataUsecase.sendSensorData(reading)) {
          anySent = true;
        }
      }
      if (!anySent) {
        // The setup-mismatch case (no recognized values) was already ruled out by the
        // sensorValues.isEmpty check above, so this means every send failed (server
        // rejection, auth, etc.) — show the generic error, not the setup-specific one.
        await handleSomethingWentWrong(null);
        return;
      }
      //can be done in the background, therefore there is no need to await
      _sendLocationDataUsecase.readAndSendLocationData();
    } catch (e) {
      handleSomethingWentWrong(e);
    } finally {
      isSendingData.value = false;
    }
  }

  void sensorHistory() {
    Get.toNamed(Routes.sensorDataHistory);
  }
}

enum SensorSlotStatus {
  idle,
  scanning,
  found,
  notFound,
  bluetoothOff,
  busy,
  error,
}

/// Tracks one assigned sensor's own connection attempt so the screen can render it (and let the
/// user retry it) independently of the others.
class SensorSlot {
  final String sensorTypeCode;
  final String displayName;
  final Rx<SensorSlotStatus> status = SensorSlotStatus.idle.obs;
  final RxInt secondsRemaining = 0.obs;
  final RxList<SensorDataValue> values = <SensorDataValue>[].obs;
  final RxString errorMessage = ''.obs;

  SensorSlot({required this.sensorTypeCode, required this.displayName});
}
