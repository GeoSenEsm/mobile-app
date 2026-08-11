import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/app_state.dart';
import 'package:survey_frontend/core/usecases/create_question_answer_dto_factory.dart';
import 'package:survey_frontend/core/usecases/read_respondent_groups_usecase.dart';
import 'package:survey_frontend/core/usecases/send_location_data_usecase.dart';
import 'package:survey_frontend/core/usecases/sensor_bind_key_store.dart';
import 'package:survey_frontend/core/usecases/submit_survey_usecase.dart';
import 'package:survey_frontend/core/usecases/survey_images_usecase.dart';
import 'package:survey_frontend/core/usecases/survey_notification_usecase.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:survey_frontend/data/models/short_survey.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/sensor_mac_service.dart';
import 'package:survey_frontend/domain/external_services/short_survey_service.dart';
import 'package:survey_frontend/domain/external_services/survey_settings_service.dart';
import 'package:survey_frontend/domain/local_services/notification_service.dart';
import 'package:survey_frontend/domain/models/create_survey_response_dto.dart';
import 'package:survey_frontend/domain/models/localization_data.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';
import 'package:survey_frontend/domain/models/survey_with_time_slots.dart';
import 'package:survey_frontend/domain/models/visibility_type.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/controllers/menu_controller.dart';
import 'package:survey_frontend/presentation/functions/ask_for_permissions.dart';
import 'package:survey_frontend/presentation/screens/home/widgets/request.dart';
import 'package:survey_frontend/presentation/static/routes.dart';
import 'package:survey_frontend/core/utils/study_time_zone.dart';

class HomeController extends ControllerBase with WidgetsBindingObserver {
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
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final SendLocationDataUsecase _sendLocationDataUsecase;
  final SensorMacService _sensorMacService;
  final SurveySettingsService _surveySettingsService;
  final SensorBindKeyStore _sensorBindKeyStore = const SensorBindKeyStore();
  final RxnString logoUrl = RxnString();
  final AppState _appState;

  HomeController(
      this._homeService,
      this._createQuestionAnswerDtoFactory,
      this._readResopndentGroupdUseCase,
      this._databaseHelper,
      this._surveyNotificationUseCase,
      this._surveyImagesUseCase,
      this._submitSurveyUsecase,
      this._storage,
      this._sendLocationDataUsecase,
      this._sensorMacService,
      this._surveySettingsService,
      this._appState);

  @override
  void onInit() async {
    super.onInit();
    askForPermissions();
    listenToNotifications();
    _storage.write("loggedBefore", true);
    logoUrl.value = _buildLogoUrl(
      _storage.read<String>(SurveySettings.logoPathStorageKey),
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      triggerPullToRefresh();
    }
  }

  void triggerPullToRefresh() {
    refreshIndicatorKey.currentState?.show();
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

    await _sendLocationDataUsecase.sendLocationData(null);

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
      await _surveyNotificationUseCase.scheduleSurveysNotifications();
    }

    await _syncMobileSensorSetup();
    await _syncSurveySettings();
  }

  Future<void> _syncSurveySettings() async {
    try {
      final response = await _surveySettingsService.getSettings();
      if (response.statusCode != 200 || response.body == null) {
        return;
      }
      final settings = response.body!;
      _storage.write(
        SurveySettings.showSendingPolicyCalendarStorageKey,
        settings.showSendingPolicyCalendar,
      );
      if (Get.isRegistered<ManuController>()) {
        Get.find<ManuController>().applySendingPolicyCalendarVisibility(
          settings.showSendingPolicyCalendar,
        );
      }
      if (settings.logoPath == null) {
        _storage.remove(SurveySettings.logoPathStorageKey);
      } else {
        _storage.write(
          SurveySettings.logoPathStorageKey,
          settings.logoPath,
        );
      }
      logoUrl.value = _buildLogoUrl(settings.logoPath);
    } on Exception catch (e) {
      Sentry.captureException(e);
    }
  }

  String? _buildLogoUrl(String? logoPath) {
    if (logoPath == null || logoPath.isEmpty) {
      return null;
    }
    return (_storage.read<String>('apiUrl') ?? '') + logoPath;
  }

  Future<void> _syncAssignedSensor() async {
    try {
      final assigned = await _sensorMacService.getAssignedSensor();
      if (assigned.statusCode != 200 || assigned.body == null) {
        return;
      }
      final body = assigned.body!;
      final kind = SensorKind.fromTypeCode(body.sensorTypeCode);
      _storage.write('selectedSensor', kind);
      _storage.write('selectedSensorId', body.sensorId);
      _storage.write('selectedSensorMac', body.sensorMac);
      _storage.remove('xiaomiMac');
    } on Exception catch (e) {
      Sentry.captureException(e);
    }
  }

  Future<void> _syncMobileSensorSetup() async {
    try {
      final response = await _surveySettingsService.getMobileSensorSetup();
      if (response.statusCode != 200 || response.body == null) {
        await _syncAssignedSensor();
        return;
      }

      final setup = response.body!;
      final secretsByMacId = {
        for (final s in setup.deviceSecrets) s.sensorMacId: s.secrets,
      };
      for (final assignment in setup.assignments) {
        final macId = assignment.sensorMacId;
        if (macId == null) continue;
        final bindKey = secretsByMacId[macId]?['bind_key'];
        if (bindKey != null) {
          await _sensorBindKeyStore.write(
              assignment.sensorTypeCode, assignment.sensorId, bindKey);
        } else {
          await _sensorBindKeyStore.delete(
              assignment.sensorTypeCode, assignment.sensorId);
        }
      }
      _storage.write(MobileSensorSetup.sensorModeKey, setup.mode);
      _storage.write(MobileSensorSetup.storageKey, jsonEncode(setup.toJson()));
      if (Get.isRegistered<ManuController>()) {
        Get.find<ManuController>().syncSensorVisibilityFromStorage();
      }

      if (setup.mode == MobileSensorSetup.noSensorData ||
          setup.assignments.isEmpty) {
        _storage.write('selectedSensor', SensorKind.none);
        _storage.remove('selectedSensorId');
        _storage.remove('selectedSensorMac');
        _storage.remove('xiaomiMac');
        return;
      }

      final enabledTypeCodes = setup.sensorTypes
          .where((type) => type.enabled)
          .map((type) => type.sensorTypeCode)
          .toSet();
      final assignment = setup.assignments
          .where((assignment) =>
              assignment.enabled &&
              (assignment.sensorTypeCode == SensorKind.manual ||
                  enabledTypeCodes.contains(assignment.sensorTypeCode)))
          .toList()
        ..sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
      if (assignment.isEmpty) {
        _storage.write('selectedSensor', SensorKind.none);
        return;
      }

      final first = assignment.first;
      final kind = SensorKind.fromTypeCode(first.sensorTypeCode);
      _storage.write('selectedSensor', kind);
      _storage.write('selectedSensorId', first.sensorId);
      _storage.write('selectedSensorMac', first.sensorMac);
      _storage.remove('xiaomiMac');
    } on Exception catch (e) {
      Sentry.captureException(e);
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

      if (!await _ensureSensorSelected()) {
        return;
      }

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
      // A dedicated read is no longer kicked off here: any reading the
      // background task or manual Sensors screen already obtains while the
      // survey is open gets attributed to it (see AppState.isSurveyActive).
      // A fresh read is only made at submit time if none arrived meanwhile.
      _appState.isSurveyActive = true;
      _appState.currentSurveySensorData.clear();
      final triggerableSectionActivationsCounts =
          _getTriggerableSectionActivationsCounts(survey);
      await Get.toNamed("/surveystart", arguments: {
        "shortSurveyInfo": shortSurveyInfo,
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
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever ||
          locationPermission == LocationPermission.unableToDetermine) {
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
    if (_storage.read<String>(MobileSensorSetup.sensorModeKey) ==
        MobileSensorSetup.noSensorData) {
      return true;
    }
    final selectedSensor = _storage.read('selectedSensor');
    if (selectedSensor == null || !SensorKind.usesBluetooth(selectedSensor)) {
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
        startDate: StudyTimeZone.nowWithLocalOffsetIso8601(),
        answers: questionAnswerDtos,
        sensorData: null);
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
    final double? accuracy =
        currentLocation.accuracy >= 0 && currentLocation.accuracy < 99999
            ? double.parse(currentLocation.accuracy.toStringAsFixed(2))
            : null;
    return LocalizationData(
        dateTime: DateTime.now().toUtc().toIso8601String(),
        latitude: double.parse(currentLocation.latitude.toStringAsFixed(6)),
        longitude: double.parse(currentLocation.longitude.toStringAsFixed(6)),
        accuracyMeters: accuracy);
  }

  Future<bool> _ensureSensorSelected() async {
    if (_storage.read<String>(MobileSensorSetup.sensorModeKey) ==
        MobileSensorSetup.noSensorData) {
      return true;
    }
    final selectedSensor = _storage.read<String>('selectedSensor');

    if (selectedSensor == null || selectedSensor == SensorKind.none) {
      final result = await showDialog<bool>(
        context: Get.context!,
        builder: (context) {
          return AlertDialog(
            title: Text(getAppLocalizations().warning),
            content: Text(getAppLocalizations().noSensorSelected),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(getAppLocalizations().continueWithoutSensor),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(getAppLocalizations().ok),
              ),
            ],
          );
        },
      );

      return result ?? false;
    }

    return true;
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
