import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/usecases/create_question_answer_dto_factory.dart';
import 'package:survey_frontend/core/usecases/read_respondent_groups_usecase.dart';
import 'package:survey_frontend/core/usecases/submit_survey_usecase.dart';
import 'package:survey_frontend/core/usecases/survey_images_usecase.dart';
import 'package:survey_frontend/core/usecases/survey_notification_usecase.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:survey_frontend/data/models/short_survey.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/short_survey_service.dart';
import 'package:survey_frontend/domain/local_services/notification_service.dart';
import 'package:survey_frontend/domain/models/create_survey_response_dto.dart';
import 'package:survey_frontend/domain/models/localization_data.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';
import 'package:survey_frontend/domain/models/survey_with_time_slots.dart';
import 'package:survey_frontend/domain/models/visibility_type.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/screens/home/widgets/request.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class HomeController extends ControllerBase {
  final ShortSurveyService _homeService;
  final CreateQuestionAnswerDtoFactory _createQuestionAnswerDtoFactory;
  final ReadResopndentGroupdUseCase _readResopndentGroupdUseCase;
  RxList<SurveyShortInfo> pendingSurveys = <SurveyShortInfo>[].obs;
  final DatabaseHelper _databaseHelper;
  final SurveyNotificationUseCase _surveyNotificationUseCase;
  final SurveyImagesUseCase _surveyImagesUseCase;
  final SubmitSurveyUsecase _submitSurveyUsecase;
  final RxInt hoursLeft = 0.obs;
  final RxInt minutesLeft = 0.obs;
  bool _isBusy = false;
  final GetStorage _storage;

  HomeController(
      this._homeService,
      this._createQuestionAnswerDtoFactory,
      this._readResopndentGroupdUseCase,
      this._databaseHelper,
      this._surveyNotificationUseCase,
      this._surveyImagesUseCase,
      this._submitSurveyUsecase,
      this._storage) {
    listenToNotifications();
  }

  listenToNotifications() {
    NotificationService.onClickNotification.listen((event) {
      startCompletingSurvey(event);
    });
  }

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

    if (response.error != null || response.statusCode != 200) {
      return;
    }
    await _databaseHelper.clearAllSurveysRelatedTables();

    if (response.body!.isNotEmpty) {
      await _surveyImagesUseCase.saveImages(response.body!);
      await _databaseHelper.upsertSurveys(response.body!);
    }
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
      // TODO check if survey still active

      final shortSurveyInfo =
          pendingSurveys.firstWhereOrNull((element) => element.id == surveyId);

      if (shortSurveyInfo == null) {
        await popup(AppLocalizations.of(Get.context!)!.error,
            AppLocalizations.of(Get.context!)!.loadingSurveyError);
        return;
      }

      if (shortSurveyInfo.finishTime.toLocal().isBefore(DateTime.now())) {
        await popup(AppLocalizations.of(Get.context!)!.error,
            AppLocalizations.of(Get.context!)!.surveyFinished);
        refreshData();
        return;
      }

      _isBusy = true;
      if (!await isLocationWorking() || !await isBluetoothWorking()) {
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

  Future<bool> isBluetoothWorking() async {
    final selectedSensor = _storage.read('selectedSensor');
    if (selectedSensor == null || selectedSensor == SensorKind.none) {
      return true;
    }
    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      popup(getAppLocalizations().bluetooth,
          getAppLocalizations().bluetoothRequired);
      return false;
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
    await _setRemainingTime();
    await _surveyNotificationUseCase.scheduleSurveysNotifications();
  }

  Future<void> _setRemainingTime() async {
    final mostUrgentSurvey = _getMostUrgentSurvey();

    if (mostUrgentSurvey == null) {
      hoursLeft.value = 0;
      minutesLeft.value = 0;
      return;
    }

    final now = DateTime.now().toUtc();
    final mostUrgentSurveyDuration =
        mostUrgentSurvey.finishTime.difference(now);
    hoursLeft.value = mostUrgentSurveyDuration.inHours;
    minutesLeft.value =
        mostUrgentSurveyDuration.inMinutes - hoursLeft.value * 60;
  }

  SurveyShortInfo? _getMostUrgentSurvey() {
    if (pendingSurveys.isEmpty) {
      return null;
    }

    return pendingSurveys
        .reduce((a, b) => a.finishTime.isBefore(b.finishTime) ? a : b);
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
