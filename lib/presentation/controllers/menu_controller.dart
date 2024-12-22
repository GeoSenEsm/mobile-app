import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class ManuController extends ControllerBase {
  void privacySettings(){
    Get.toNamed(Routes.privacySettings);
  }

  void notifications(){
    Get.toNamed(Routes.notifications);
  }

  void editSensor(){
    Get.toNamed(Routes.sensors);
  }

  void changePassword(){
    Get.toNamed(Routes.changePassword);
  }

  void logout(){
    Get.toNamed(Routes.logoutConfirmation);
  }

  void sensorData() {
    Get.toNamed(Routes.sensorDataScreen);
  }

  void calendar() {
    Get.toNamed(Routes.calendar);
  }

  void sensorHistory(){
    Get.toNamed(Routes.sensorDataHistory);
  }
}