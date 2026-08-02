import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/app_state.dart';
import 'package:survey_frontend/core/usecases/send_location_data_usecase.dart';
import 'package:survey_frontend/core/usecases/send_sensors_data_usecase.dart';
import 'package:survey_frontend/core/usecases/submit_survey_usecase.dart';
import 'package:survey_frontend/core/usecases/survey_notification_id_usecase.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/location_model.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:survey_frontend/data/models/short_survey.dart';
import 'package:survey_frontend/domain/local_services/notification_service.dart';
import 'package:survey_frontend/domain/models/create_survey_response_dto.dart';
import 'package:survey_frontend/domain/models/localization_data.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';
import 'package:survey_frontend/domain/models/survey_participation_dto.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/static/routes.dart';
import 'package:survey_frontend/core/utils/study_time_zone.dart';

class SurveyEndController extends ControllerBase {
  late CreateSurveyResponseDto dto;
  late Future<LocalizationData> localizationData;
  late Future<SensorData?> futureSensorData;
  final SendLocationDataUsecase _sendLocationDataUsecase;
  final DatabaseHelper _databaseHelper;
  final SubmitSurveyUsecase _submitSurveyUsecase;
  final SurveyNotificationIdUsecase _surveyNotificationIdUsecase;
  late SurveyShortInfo surveyShortInfo;
  final GetStorage _storage;
  final AppState _appState;
  Rx isBusy = false.obs;

  SurveyEndController(
      this._sendLocationDataUsecase,
      this._databaseHelper,
      this._submitSurveyUsecase,
      this._surveyNotificationIdUsecase,
      this._storage,
      this._appState);

  void endSurvey() async {
    if (isBusy.value) {
      return;
    }

    try {
      isBusy.value = true;
      final participation = await _submitToServer();
      //no need to await, let's do it in background
      _saveLocation(participation?.id);
      final notificationCount =
          await _databaseHelper.getSurveyNotificationCount(surveyShortInfo.id);
      for (var i = 0; i < notificationCount; i++) {
        NotificationService.cancelNotification(
            _surveyNotificationIdUsecase.getNotificationId(surveyShortInfo, i));
      }
      await _databaseHelper.markAsSubmited(dto.surveyId);
      _appState.justSubmitedSurvey = true;
      Get.until((route) => Get.currentRoute == Routes.home);
    } catch (e) {
      popup(AppLocalizations.of(Get.context!)!.error,
          AppLocalizations.of(Get.context!)!.mainPageTransitionError);
      Sentry.captureException(e);
    } finally {
      isBusy.value = false;
    }
  }

  Future<SurveyParticipationDto?> _submitToServer() async {
    try {
      final sensorData =
          await _collectManualSensorDataIfNeeded(await futureSensorData);
      await _checkSensorDataRead(sensorData);
      dto.sensorData = sensorData;
      _clearDto();
      dto.finishDate = StudyTimeZone.nowWithLocalOffsetIso8601();
      final participation = await _submitSurveyUsecase.submitSurvey(dto);
      return participation;
    } catch (e) {
      popup(AppLocalizations.of(Get.context!)!.error,
          AppLocalizations.of(Get.context!)!.mainPageTransitionError);
      Sentry.captureException(e);
      return null;
    }
  }

  Future<void> _checkSensorDataRead(SensorData? sensorData) async {
    if (sensorData != null || !_isSensorSelected()) {
      return;
    }

    if (sensorData == null) {
      await Get.defaultDialog(
          title: getAppLocalizations().sensorNotFoundDialogTitle,
          middleText: getAppLocalizations().sensorNotFoundDialogContent,
          textConfirm: getAppLocalizations().ok,
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
          });
    }
  }

  Future<SensorData?> _collectManualSensorDataIfNeeded(
      SensorData? sensorData) async {
    if (sensorData != null || !_hasManualFallback()) {
      return sensorData;
    }

    final setup = _readSensorSetup();
    if (setup == null) {
      return null;
    }
    final parameters =
        setup.parameters.where((parameter) => parameter.active).toList();
    if (parameters.isEmpty) {
      return null;
    }

    final controllers = {
      for (final parameter in parameters)
        parameter.code: TextEditingController()
    };
    final shouldSubmit = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Enter sensor data manually'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: parameters
                .map((parameter) => TextField(
                      controller: controllers[parameter.code],
                      decoration: InputDecoration(
                        labelText: parameter.unit == null
                            ? parameter.name
                            : '${parameter.name} (${parameter.unit})',
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(getAppLocalizations().cancel)),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(getAppLocalizations().ok)),
        ],
      ),
      barrierDismissible: false,
    );

    if (shouldSubmit != true) {
      return null;
    }

    final values = parameters
        .map((parameter) => SensorDataValue(
              parameterCode: parameter.code,
              value: controllers[parameter.code]!.text,
            ))
        .where((value) => value.value.trim().isNotEmpty)
        .toList();

    if (values.isEmpty) {
      return null;
    }

    return SensorData(
        dateTime: DateTime.now().toUtc().toIso8601String(),
        source: 'manual',
        values: values);
  }

  bool _hasManualFallback() {
    final setup = _readSensorSetup();
    return setup?.assignments.any((assignment) =>
            assignment.enabled && assignment.sensorTypeCode == 'manual') ??
        false;
  }

  MobileSensorSetup? _readSensorSetup() {
    final raw = _storage.read<String>(MobileSensorSetup.storageKey);
    if (raw == null) {
      return null;
    }
    return MobileSensorSetup.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  bool _isSensorSelected() {
    final selectedSensor = _storage.read<String>('selectedSensor');
    final mode = _storage.read<String>(MobileSensorSetup.sensorModeKey);
    return mode != MobileSensorSetup.noSensorData &&
        selectedSensor != null &&
        selectedSensor != SensorKind.none &&
        selectedSensor != SensorKind.manual;
  }

  Future<void> _saveLocation(String? surveyParticipationId) async {
    try {
      final location = await localizationData;

      final model = LocationModel(
          dateTime: DateTime.parse(dto.startDate),
          longitude: location.longitude,
          latitude: location.latitude,
          sentToServer: false,
          relatedToSurvey: true,
          surveyParticipationId: surveyParticipationId,
          accuracyMeters: location.accuracyMeters);
      await _sendLocationDataUsecase.sendLocationData(model);
    } catch (e) {
      Sentry.captureException(e);
    }
  }

  void _clearDto() {
    for (final answer in dto.answers) {
      if (answer.selectedOptions == null) {
        continue;
      }

      for (int i = 0; i < answer.selectedOptions!.length; i++) {
        if (answer.selectedOptions![i].optionId == null) {
          answer.selectedOptions!.removeAt(i);
          i--;
        }
      }
    }

    dto.answers = dto.answers.where((e) {
      //TODO: extend this, when we have a new text input question type
      return e.yesNoAnswer != null ||
          e.numericAnswer != null ||
          e.textAnswer != null ||
          (e.selectedOptions != null &&
              e.selectedOptions!.isNotEmpty &&
              e.selectedOptions!.every((e) => e.optionId != null));
    }).toList();
  }

  void readGetArgs() {
    dto = Get.arguments['responseModel'];
    localizationData = Get.arguments['localizationData'];
    futureSensorData = Get.arguments['futureSensorData'];
    surveyShortInfo = Get.arguments['shortSurveyInfo'];
  }
}
