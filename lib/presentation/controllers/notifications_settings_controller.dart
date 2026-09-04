import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/usecases/survey_notification_usecase.dart';
import 'package:survey_frontend/domain/local_services/notification_service.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';

class NotificationsSettingsController extends ControllerBase {
  final GetStorage _storage;
  final SurveyNotificationUseCase _surveyNotificationUseCase;
  final RxBool notifyAboutSurveys = true.obs;
  bool _originalNotifyAboutSurveys = true;
  bool _busy = false;

  NotificationsSettingsController(
      this._storage, this._surveyNotificationUseCase);

  void loadSettings() {
    notifyAboutSurveys.value = _originalNotifyAboutSurveys =
        _storage.read<bool>('notifyAboutSurveys') ?? true;
  }

  void save() async {
    if (_busy) {
      return;
    }

    try {
      _busy = true;
      if (notifyAboutSurveys.value != _originalNotifyAboutSurveys) {
        await saveNewValue();
      }
      Get.back();
    } catch (e) {
      handleSomethingWentWrong(e);
    } finally {
      _busy = false;
    }
  }

  Future<void> saveNewValue() async {
    if (notifyAboutSurveys.value) {
      await _surveyNotificationUseCase.scheduleSurveysNotifications();
    } else {
      await NotificationService.cancelAllNotifications();
    }

    await _storage.write('notifyAboutSurveys', notifyAboutSurveys.value);
  }
}
