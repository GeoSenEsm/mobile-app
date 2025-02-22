import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/usecases/send_location_data_usecase.dart';
import 'package:survey_frontend/core/usecases/send_sensors_data_usecase.dart';
import 'package:survey_frontend/core/usecases/submit_survey_usecase.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/location_model.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:survey_frontend/domain/models/create_survey_response_dto.dart';
import 'package:survey_frontend/domain/models/localization_data.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';
import 'package:survey_frontend/domain/models/survey_participation_dto.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class SurveyEndController extends ControllerBase {
  late CreateSurveyResponseDto dto;
  late Future<LocalizationData> localizationData;
  late Future<SensorData?> futureSensorData;
  final SendLocationDataUsecase _sendLocationDataUsecase;
  final DatabaseHelper _databaseHelper;
  final SubmitSurveyUsecase _submitSurveyUsecase;
  final SendSensorsDataUsecase _sendSensorsDataUsecase;
  final GetStorage _storage;
  Rx isBusy = false.obs;

  SurveyEndController(
      this._sendLocationDataUsecase,
      this._databaseHelper,
      this._submitSurveyUsecase,
      this._sendSensorsDataUsecase,
      this._storage);

  void endSurvey() async {
    if (isBusy.value) {
      return;
    }

    try {
      isBusy.value = true;
      final participation = await _submitToServer();
      //no need to await, let's do it in background
      _saveLocation(participation?.id);

      await _databaseHelper.markAsSubmited(dto.surveyId);
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
      final sensorData = await futureSensorData;
      await _checkSensorDataRead(sensorData);
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

  Future<void> _checkSensorDataRead(SensorData? sensorData) async{
    if (sensorData != null || !_isSensorSelected()){
      return;
    }

    if (sensorData == null) {
      await Get.defaultDialog(
        title: getAppLocalizations().sensorNotFoundDialogTitle,
        middleText: getAppLocalizations().sensorNotFoundDialogContent,
        textConfirm: getAppLocalizations().ok,
        confirmTextColor: Colors.white,
        onConfirm: (){
          Get.back();
        }
      );
    }
  }

  bool _isSensorSelected(){
    final selectedSensor = _storage.read<String>('selectedSensor');
    return selectedSensor != null && selectedSensor != SensorKind.none;
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

  void readGetArgs() {
    dto = Get.arguments['responseModel'];
    localizationData = Get.arguments['localizationData'];
    futureSensorData = Get.arguments['futureSensorData'];
  }
}
