import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';

/// A single row shown on the sensors screen: the display name of an
/// admin-assigned sensor and its MAC address, when it has one (profile-driven
/// sensors identified by advertised name rather than MAC won't).
class AssignedSensorView {
  final String name;
  final String? mac;
  final List<String> parameterNames;

  const AssignedSensorView(
      {required this.name, this.mac, this.parameterNames = const []});
}

/// Read-only view of the sensors an admin has assigned to this respondent.
/// Assignment data itself is entirely backend-driven (synced in
/// [HomeController._syncMobileSensorSetup] into [MobileSensorSetup.storageKey])
/// — this screen only displays it.
class SensorsController extends ControllerBase {
  final GetStorage _storage;
  final RxList<AssignedSensorView> assignedSensors = <AssignedSensorView>[].obs;

  SensorsController(this._storage) {
    _loadAssignedSensors();
  }

  void _loadAssignedSensors() {
    final raw = _storage.read<String>(MobileSensorSetup.storageKey);
    if (raw == null) {
      assignedSensors.clear();
      return;
    }
    final setup =
        MobileSensorSetup.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    final namesByCode = {
      for (final type in setup.sensorTypes)
        type.sensorTypeCode: type.sensorTypeName ?? type.sensorTypeCode,
    };
    assignedSensors.value = setup.assignments
        .map((assignment) => AssignedSensorView(
              name: assignment.sensorTypeCode == SensorKind.manual
                  ? getAppLocalizations().manualSensor
                  : namesByCode[assignment.sensorTypeCode] ??
                      assignment.sensorTypeCode,
              mac: assignment.sensorMac,
              parameterNames: setup.parameters
                  .where((parameter) =>
                      parameter.sourceFor(assignment.sensorTypeCode) != null)
                  .map((parameter) => parameter.name)
                  .toList(),
            ))
        .toList();
  }
}
