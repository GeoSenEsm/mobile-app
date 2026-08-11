import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

/// Resolves which of a respondent's enabled sensor assignments should be attempted, in what
/// order, and with what per-type timeout. Shared by [SendSensorsDataUsecaseImpl]
/// (background/ambient gathering) and [SensorDataController] (the manual Sensors screen) so both
/// attempt the same set of sensors the same way.
class SensorAssignmentPlanner {
  final GetStorage _storage;

  const SensorAssignmentPlanner(this._storage);

  MobileSensorSetup? readSetup() {
    final raw = _storage.read<String>(MobileSensorSetup.storageKey);
    if (raw == null) {
      return null;
    }
    return MobileSensorSetup.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  List<RespondentSensorAssignment> orderedAssignments(MobileSensorSetup? setup) {
    if (setup == null) return [];
    final enabledTypeCodes = setup.sensorTypes
        .where((t) => t.enabled)
        .map((t) => t.sensorTypeCode)
        .toSet();
    final assignments = setup.assignments
        .where((a) => a.enabled && enabledTypeCodes.contains(a.sensorTypeCode))
        .toList();
    assignments.sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
    return assignments;
  }

  Duration timeoutFor(
      MobileSensorSetup? setup, RespondentSensorAssignment assignment) {
    final typeSetting = setup?.sensorTypes.firstWhere(
      (type) => type.sensorTypeCode == assignment.sensorTypeCode,
      orElse: () => const SensorTypeSetting(
          sensorTypeCode: '',
          sensorTypeName: null,
          enabled: false,
          connectionTimeoutSeconds: 30,
          displayOrder: 0),
    );
    return Duration(seconds: typeSetting?.connectionTimeoutSeconds ?? 30);
  }
}
