import 'package:survey_frontend/domain/models/gatt_profile.dart';

class SurveySettings {
  static const String showSendingPolicyCalendarStorageKey =
      'showSendingPolicyCalendar';
  static const String logoPathStorageKey = 'surveySettingsLogoPath';

  final bool showSendingPolicyCalendar;
  final String? logoPath;

  const SurveySettings({
    required this.showSendingPolicyCalendar,
    this.logoPath,
  });

  factory SurveySettings.fromJson(Map<String, dynamic> json) {
    return SurveySettings(
      showSendingPolicyCalendar:
          json['showSendingPolicyCalendar'] as bool? ?? true,
      logoPath: json['logoPath'] as String?,
    );
  }
}

class MobileSensorSetup {
  static const String storageKey = 'mobileSensorSetup';
  static const String sensorModeKey = 'sensorDataMode';
  static const String noSensorData = 'no_sensor_data';
  static const String configuredSensors = 'configured_sensors';

  final String mode;
  final List<SensorTypeSetting> sensorTypes;
  final List<SensorParameterDefinition> parameters;
  final List<RespondentSensorAssignment> assignments;
  final List<GattProfile> gattProfiles;

  const MobileSensorSetup({
    required this.mode,
    required this.sensorTypes,
    required this.parameters,
    required this.assignments,
    this.gattProfiles = const [],
  });

  factory MobileSensorSetup.fromJson(Map<String, dynamic> json) {
    return MobileSensorSetup(
      mode: json['mode'] as String? ?? noSensorData,
      sensorTypes: (json['sensorTypes'] as List<dynamic>? ?? [])
          .map((e) => SensorTypeSetting.fromJson(e as Map<String, dynamic>))
          .toList(),
      parameters: (json['parameters'] as List<dynamic>? ?? [])
          .map((e) =>
              SensorParameterDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      assignments: (json['assignments'] as List<dynamic>? ?? [])
          .map((e) =>
              RespondentSensorAssignment.fromJson(e as Map<String, dynamic>))
          .toList(),
      gattProfiles: (json['gattProfiles'] as List<dynamic>? ?? [])
          .map((e) => GattProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'sensorTypes': sensorTypes.map((e) => e.toJson()).toList(),
        'parameters': parameters.map((e) => e.toJson()).toList(),
        'assignments': assignments.map((e) => e.toJson()).toList(),
        'gattProfiles': gattProfiles.map((e) => e.toJson()).toList(),
      };
}

class SensorTypeSetting {
  final String sensorTypeCode;
  final String? sensorTypeName;
  final bool enabled;
  final int connectionTimeoutSeconds;
  final int displayOrder;
  final String integrationMode;

  const SensorTypeSetting({
    required this.sensorTypeCode,
    required this.sensorTypeName,
    required this.enabled,
    required this.connectionTimeoutSeconds,
    required this.displayOrder,
    this.integrationMode = 'profile',
  });

  factory SensorTypeSetting.fromJson(Map<String, dynamic> json) {
    return SensorTypeSetting(
      sensorTypeCode: json['sensorTypeCode'] as String,
      sensorTypeName: json['sensorTypeName'] as String?,
      enabled: json['enabled'] as bool? ?? false,
      connectionTimeoutSeconds: json['connectionTimeoutSeconds'] as int? ?? 30,
      displayOrder: json['displayOrder'] as int? ?? 0,
      integrationMode: json['integrationMode'] as String? ?? 'profile',
    );
  }

  Map<String, dynamic> toJson() => {
        'sensorTypeCode': sensorTypeCode,
        'sensorTypeName': sensorTypeName,
        'enabled': enabled,
        'connectionTimeoutSeconds': connectionTimeoutSeconds,
        'displayOrder': displayOrder,
        'integrationMode': integrationMode,
      };
}

class SensorParameterDefinition {
  final String code;
  final String name;
  final String dataType;
  final String? unit;
  final List<SensorParameterSource> sources;

  const SensorParameterDefinition({
    required this.code,
    required this.name,
    required this.dataType,
    required this.unit,
    this.sources = const [],
  });

  /// Whether [sensorTypeCode] is a configured source for this parameter, and if so, the raw
  /// field name that sensor type's reading uses (which may differ from [code]).
  SensorParameterSource? sourceFor(String sensorTypeCode) {
    for (final source in sources) {
      if (source.sensorTypeCode == sensorTypeCode) {
        return source;
      }
    }
    return null;
  }

  factory SensorParameterDefinition.fromJson(Map<String, dynamic> json) {
    return SensorParameterDefinition(
      code: json['code'] as String,
      name: json['name'] as String,
      dataType: json['dataType'] as String? ?? 'text',
      unit: json['unit'] as String?,
      sources: (json['sources'] as List<dynamic>? ?? [])
          .map((e) => SensorParameterSource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'dataType': dataType,
        'unit': unit,
        'sources': sources.map((e) => e.toJson()).toList(),
      };
}

/// One configured source feeding a [SensorParameterDefinition]: a specific sensor type's raw
/// field (`rawParameterCode`, which may differ from the parameter's own `code`). `manual` is a
/// real, selectable `sensorTypeCode` here too — every parameter is guaranteed to have it wired
/// as a fallback source, not just physical sensors.
class SensorParameterSource {
  final String sensorTypeCode;
  final String rawParameterCode;

  const SensorParameterSource({
    required this.sensorTypeCode,
    required this.rawParameterCode,
  });

  factory SensorParameterSource.fromJson(Map<String, dynamic> json) {
    return SensorParameterSource(
      sensorTypeCode: json['sensorTypeCode'] as String,
      rawParameterCode: json['rawParameterCode'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'sensorTypeCode': sensorTypeCode,
        'rawParameterCode': rawParameterCode,
      };
}

class RespondentSensorAssignment {
  final String sensorTypeCode;
  final String? sensorId;
  final String? sensorMac;
  final String? sensorMacId;

  const RespondentSensorAssignment({
    required this.sensorTypeCode,
    required this.sensorId,
    required this.sensorMac,
    this.sensorMacId,
  });

  factory RespondentSensorAssignment.fromJson(Map<String, dynamic> json) {
    return RespondentSensorAssignment(
      sensorTypeCode: json['sensorTypeCode'] as String,
      sensorId: json['sensorId'] as String?,
      sensorMac: json['sensorMac'] as String?,
      sensorMacId: json['sensorMacId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'sensorTypeCode': sensorTypeCode,
        'sensorId': sensorId,
        'sensorMac': sensorMac,
        if (sensorMacId != null) 'sensorMacId': sensorMacId,
      };
}
