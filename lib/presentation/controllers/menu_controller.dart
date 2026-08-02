import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/domain/external_services/survey_settings_service.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class ManuController extends ControllerBase {
  final SurveySettingsService _surveySettingsService;
  final GetStorage _storage;
  final RxBool showSendingPolicyCalendar = true.obs;

  ManuController(this._surveySettingsService, this._storage) {
    final cached =
        _storage.read<bool>(SurveySettings.showSendingPolicyCalendarStorageKey);
    if (cached != null) {
      showSendingPolicyCalendar.value = cached;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadSurveySettings();
  }

  Future<void> loadSurveySettings() async {
    final response = await _surveySettingsService.getSettings();
    if (response.statusCode != 200 || response.body == null) {
      return;
    }
    applySendingPolicyCalendarVisibility(
        response.body!.showSendingPolicyCalendar);
  }

  void applySendingPolicyCalendarVisibility(bool enabled) {
    showSendingPolicyCalendar.value = enabled;
    _storage.write(
        SurveySettings.showSendingPolicyCalendarStorageKey, enabled);
  }

  void syncCalendarVisibilityFromStorage() {
    final cached =
        _storage.read<bool>(SurveySettings.showSendingPolicyCalendarStorageKey);
    if (cached != null) {
      showSendingPolicyCalendar.value = cached;
    }
  }

  void privacySettings() {
    Get.toNamed(Routes.privacySettings);
  }

  void notifications() {
    Get.toNamed(Routes.notifications);
  }

  void editSensor() {
    Get.toNamed(Routes.sensors);
  }

  void changePassword() {
    Get.toNamed(Routes.changePassword);
  }

  void logout() {
    Get.toNamed(Routes.logoutConfirmation);
  }

  void sensorData() {
    Get.toNamed(Routes.sensorDataScreen);
  }

  void calendar() {
    if (!showSendingPolicyCalendar.value) {
      return;
    }
    Get.toNamed(Routes.calendar);
  }

  void sensorHistory() {
    Get.toNamed(Routes.sensorDataHistory);
  }

  void map() {
    Get.toNamed(Routes.map);
  }

  void contact() {
    Get.toNamed(Routes.contact);
  }
}
