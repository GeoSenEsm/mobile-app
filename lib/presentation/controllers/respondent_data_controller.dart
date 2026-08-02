import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';

class RespondentDataController extends ControllerBase{
  Rx<String?> gender = "Male".obs;
  Rx<String?> ageCategory = "50-59".obs;
  Rx<String?> occupationCategory = "Employed".obs;
  Rx<String?> educationCategory = "Secondary".obs;
  
  Rx<String?> healthCondition = "good".obs;
  Rx<String?> medicationUse = "no".obs; 
  
  Rx<String?> lifeSatisfaction = "good".obs;
  Rx<String?> stressLevel = "medium".obs; 
  Rx<String?> qualityOfSleep = "high".obs; 
}