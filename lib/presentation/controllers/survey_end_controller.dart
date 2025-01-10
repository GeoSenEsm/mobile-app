import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/usecases/send_location_data_usecase.dart';
import 'package:survey_frontend/core/usecases/send_sensors_data_usecase.dart';
import 'package:survey_frontend/core/usecases/submit_survey_usecase.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/location_model.dart';
import 'package:survey_frontend/domain/models/create_survey_response_dto.dart';
import 'package:survey_frontend/domain/models/localization_data.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';
import 'package:survey_frontend/domain/models/survey_participation_dto.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyEndController extends ControllerBase {
  late CreateSurveyResponseDto dto;
  late Future<LocalizationData> localizationData;
  late Future<SensorData?> futureSensorData;
  final SendLocationDataUsecase _sendLocationDataUsecase;
  final DatabaseHelper _databaseHelper;
  final SubmitSurveyUsecase _submitSurveyUsecase;
  final SendSensorsDataUsecase _sendSensorsDataUsecase;
  bool _isBusy = false;

  SurveyEndController(
      this._sendLocationDataUsecase,
      this._databaseHelper,
      this._submitSurveyUsecase,
      this._sendSensorsDataUsecase);

  void endSurvey() async {
    if (_isBusy) {
      return;
    }

    try {
      _isBusy = true;
      final participation = await _submitToServer();
      //no need to await, let's do it in background
      _saveLocation(participation?.id);

      await _databaseHelper.markAsSubmited(dto.surveyId);
      await Get.offAllNamed(
        "/home",
      );
    } catch (e) {
      popup(AppLocalizations.of(Get.context!)!.error,
          AppLocalizations.of(Get.context!)!.mainPageTransitionError);
      Sentry.captureException(e);
    } finally {
      _isBusy = false;
    }
  }

  Future<SurveyParticipationDto?> _submitToServer() async {
    try {
      final sensorData = await futureSensorData;
      dto.sensorData = sensorData;
      _clearDto();
      dto.finishDate = DateTime.now().toUtc().toIso8601String();
      final participation = _submitSurveyUsecase.submitSurvey(dto);
      return participation;
    } catch (e) {
      popup(AppLocalizations.of(Get.context!)!.error,
          AppLocalizations.of(Get.context!)!.mainPageTransitionError);
      Sentry.captureException(e);
      return null;
    }
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
          surveyParticipationId: surveyParticipationId);
      await _sendLocationDataUsecase.sendLocationData(model);
    } catch (e) {
      Sentry.captureException(e);
    }
  }

  void _clearDto() {
    for (final answer in dto.answers) {
      if (answer.selectedOptions == null){
        continue;
      }

      for (int i = 0; i < answer.selectedOptions!.length; i++){
        if (answer.selectedOptions![i].optionId == null){
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
          (e.selectedOptions != null && e.selectedOptions!.isNotEmpty &&
              e.selectedOptions!.every((e) => e.optionId != null));
    }).toList();
  }

  Future<void> _submitSensorData() async {
    try {
      await _sendSensorsDataUsecase.readAndSendSensorData();
    } catch (e) {
      Sentry.captureException(e);
    }
  }

  void readGetArgs() {
    dto = Get.arguments['responseModel'];
    localizationData = Get.arguments['localizationData'];
    futureSensorData = Get.arguments['futureSensorData'];
  }
}
