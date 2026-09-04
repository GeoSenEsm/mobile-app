import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';

class ArchivedSurveysController extends ControllerBase {
  RxList<String> archivedSurveys =
      ["Some archived survey", "Another archived survey"].obs;
}
