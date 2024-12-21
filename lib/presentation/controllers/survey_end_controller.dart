import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/usecases/send_sensors_data_usecase.dart';
import 'package:survey_frontend/core/usecases/submit_survey_usecase.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/domain/external_services/location_service.dart';
import 'package:survey_frontend/domain/external_services/survey_response_service.dart';
import 'package:survey_frontend/domain/local_services/survey_participation_service.dart';
import 'package:survey_frontend/domain/models/create_survey_response_dto.dart';
import 'package:survey_frontend/domain/models/localization_data.dart';
import 'package:survey_frontend/domain/models/survey_participation_dto.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyEndController extends ControllerBase {
  late CreateSurveyResponseDto dto;
  late Future<LocalizationData> localizationData;
  final LocalizationService _locationService;
  final SurveyParticipationService _surveyParticipationService;
  final DatabaseHelper _databaseHelper;
  final SubmitSurveyUsecase _submitSurveyUsecase;
  final SendSensorsDataUsecase _sendSensorsDataUsecase;
  bool _isBusy = false;

  SurveyEndController(
      this._locationService,
      this._surveyParticipationService,
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
      //no need to await, let's to it in background
      _submitSensorData();
      if (participation != null) {
        await _surveyParticipationService.addParticipation(participation);
        final location = await localizationData;
        location.surveyParticipationId = participation.id;
        final response = await _locationService.submitLocation(location);
        if (response.statusCode != 201) {
          //TODO log it
        }
      }

      await _databaseHelper.removeSurveyTimeSlot(dto.surveyId);
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

  void _clearDto() {
    dto.answers = dto.answers.where((e) {
      //TODO: extend this, when we have a new text input question type
      return e.yesNoAnswer != null ||
          e.numericAnswer != null ||
          (e.selectedOptions != null &&
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
  }
}
