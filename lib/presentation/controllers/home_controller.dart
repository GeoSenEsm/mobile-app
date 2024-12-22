import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/usecases/create_question_answer_dto_factory.dart';
import 'package:survey_frontend/core/usecases/read_respondent_groups_usecase.dart';
import 'package:survey_frontend/core/usecases/submit_survey_usecase.dart';
import 'package:survey_frontend/core/usecases/survey_images_usecase.dart';
import 'package:survey_frontend/core/usecases/survey_notification_usecase.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/short_survey.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/short_survey_service.dart';
import 'package:survey_frontend/domain/models/create_survey_response_dto.dart';
import 'package:survey_frontend/domain/models/localization_data.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';
import 'package:survey_frontend/domain/models/survey_with_time_slots.dart';
import 'package:survey_frontend/domain/models/visibility_type.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/screens/home/widgets/request.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class HomeController extends ControllerBase {
  final ShortSurveyService _homeService;
  final CreateQuestionAnswerDtoFactory _createQuestionAnswerDtoFactory;
  final ReadResopndentGroupdUseCase _readResopndentGroupdUseCase;
  RxList<SurveyShortInfo> pendingSurveys = <SurveyShortInfo>[].obs;
  final RxInt hours = 23.obs;
  final RxInt minutes = 60.obs;
  final DatabaseHelper _databaseHelper;
  final SurveyNotificationUseCase _surveyNotificationUseCase;
  final SurveyImagesUseCase _surveyImagesUseCase;
  final SubmitSurveyUsecase _submitSurveyUsecase;
  bool _isBusy = false;

  HomeController(
      this._homeService,
      this._createQuestionAnswerDtoFactory,
      this._readResopndentGroupdUseCase,
      this._databaseHelper,
      this._surveyNotificationUseCase,
      this._surveyImagesUseCase,
      this._submitSurveyUsecase);

  Future<void> refreshData() async {
    if (_isBusy) {
      return;
    }

    try {
      _isBusy = true;
      await syncWithServer();
      pendingSurveys.clear();
      await _loadFromDatabase();
    } catch (e) {
      Sentry.captureException(e);
    } finally {
      _isBusy = false;
    }
  }

  Future<void> syncWithServer() async {
    if (!await hasInternetConnectionNoDialog()) {
      return;
    }

    if (!await _submitSurveyUsecase.submitAllLocallySaved()) {
      //we can go further only if the submition of old resopnses is succeded, otherwise, there may be
      //some data inconsistency leading to respondent being asked for filling the same survey more than one in one time slot
      return;
    }

    APIResponse<List<SurveyWithTimeSlots>> response =
        await _homeService.getSurveysWithTimeSlots();

    if (response.error != null ||
        response.statusCode != 200 ||
        response.body!.isEmpty) {
      return;
    }
    await _surveyImagesUseCase.saveImages(response.body!);
    await _databaseHelper.clearAllSurveysRelatedTables();
    await _databaseHelper.upsertSurveys(response.body!);
  }

  int hoursLeft() {
    if (pendingSurveys.isEmpty) {
      return 0;
    }

    final today = DateTime.now();
    final timeFinish = Duration(hours: hours.value, minutes: minutes.value);
    final timeNow = Duration(hours: today.hour, minutes: today.minute);
    final timeLeft = timeFinish - timeNow;
    return timeLeft.inHours;
  }

  int minutesLeft() {
    if (pendingSurveys.isEmpty) {
      return 0;
    }

    final today = DateTime.now();
    final timeFinish = Duration(hours: hours.value, minutes: minutes.value);
    final timeNow = Duration(hours: today.hour, minutes: today.minute);
    final timeLeft = timeFinish - timeNow;
    return timeLeft.inMinutes.remainder(60);
  }

  bool hasTimeSlotForToday(SurveyWithTimeSlots survey) {
    final today = DateTime.now();
    return survey.surveySendingPolicyTimes.any((element) =>
        element.start.year == today.year &&
        element.start.month == today.month &&
        element.start.day == today.day);
  }

  void startCompletingSurvey(String surveyId) async {
    if (_isBusy) {
      return;
    }

    try {
      _isBusy = true;
      if (!await isLocationWorking()) {
        return;
      }
      final futures = [
        _databaseHelper.getSurveyById(surveyId),
        _getGroupsIds()
      ];
      final results = await Future.wait(futures);
      SurveyDto? survey = results[0] as SurveyDto?;
      var respondentGroups = results[1];

      if (survey == null || respondentGroups == null) {
        await popup(AppLocalizations.of(Get.context!)!.error,
            AppLocalizations.of(Get.context!)!.loadingSurveyError);
        return;
      }
      final questions = _getQuestionsFromSurvey(survey);
      final responseModel = _prepareResponseModel(questions, survey.id);
      final futureLocalizationData = _getCurrentLocation();
      final triggerableSectionActivationsCounts =
          _getTriggerableSectionActivationsCounts(survey);
      await Get.toNamed("/surveystart", arguments: {
        "survey": survey,
        "questions": questions,
        "responseModel": responseModel,
        "groups": respondentGroups,
        "triggerableSectionActivationsCounts":
            triggerableSectionActivationsCounts,
        "localizationData": futureLocalizationData
      });
    } catch (e) {
      await popup(AppLocalizations.of(Get.context!)!.error,
          AppLocalizations.of(Get.context!)!.loadingSurveyError);
    } finally {
      _isBusy = false;
    }
  }

  Future<bool> isLocationWorking() async {
    Location location = Location();
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission != LocationPermission.always &&
          locationPermission != LocationPermission.whileInUse) {
        await buildLocationDenyDialog();
        return false;
      }
    }

    bool locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      bool enabled = await location.requestService();
      if (!enabled) {
        return false;
      }
    }
    return true;
  }

  Future<List<String>?> _getGroupsIds() async {
    return (await _readResopndentGroupdUseCase.getAll())
        .map((e) => e.id)
        .toList();
  }

  List<QuestionWithSection> _getQuestionsFromSurvey(SurveyDto surveyObj) {
    return surveyObj.sections
        .expand((section) => section.questions.map((question) =>
            QuestionWithSection(question: question, section: section)))
        .toList();
  }

  CreateSurveyResponseDto _prepareResponseModel(
      List<QuestionWithSection> questions, String surveyId) {
    final questionAnswerDtos = questions
        .map((q) => _createQuestionAnswerDtoFactory.getDto(q.question))
        .toList();

    return CreateSurveyResponseDto(
        surveyId: surveyId,
        startDate: DateTime.now().toUtc().toIso8601String(),
        answers: questionAnswerDtos);
  }

  Map<int, int> _getTriggerableSectionActivationsCounts(SurveyDto survey) {
    Map<int, int> output = {};
    for (final section in survey.sections) {
      if (section.visibility == "answer_triggered") {
        output[section.order] = 0;
      }
    }
    return output;
  }

  Future<void> _loadFromDatabase() async {
    final completableNow = await _databaseHelper.getSurveysCompletableNow();
    pendingSurveys.addAll(completableNow);
    await _surveyNotificationUseCase.scheduleSurveysNotifications();
  }

  void openSettings() {
    Get.toNamed(Routes.settings);
  }

  void openProfile() {
    Get.toNamed(Routes.profile);
  }

  Future<LocalizationData> _getCurrentLocation() async {
    Position currentLocation = await Geolocator.getCurrentPosition();
    return LocalizationData(
        dateTime: DateTime.now().toUtc().toIso8601String(),
        latitude: double.parse(currentLocation.latitude.toStringAsFixed(6)),
        longitude: double.parse(currentLocation.longitude.toStringAsFixed(6)));
  }
}

class QuestionWithSection {
  final Question question;
  final Section section;
  QuestionWithSection({required this.question, required this.section});

  get id => question.id;

  bool canQuestionBeShown(List<String?> groupsIds,
      Map<int, int> triggerableSectionActivationsCounts) {
    //TODO: make a class with const strings here
    if (section.visibility == VisibilityType.groupSpecific) {
      return groupsIds.contains(section.groupId);
    }

    if (section.visibility == VisibilityType.answerTriggered) {
      return triggerableSectionActivationsCounts[section.order]! > 0;
    }
    return true;
  }
}
