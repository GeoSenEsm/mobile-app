import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/domain/models/initial_survey_question.dart';
import 'package:survey_frontend/domain/usecases/token_provider.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';

class ProfileController extends ControllerBase {
  late Map<String, dynamic> respondentData;
  late List<InitialSurveyQuestion> initialSurveyQuestions;
  final TokenProvider _tokenProvider;
  final RxString apiUrl = ''.obs;

  ProfileController(GetStorage storage, this._tokenProvider) {
    final respondentFromStorage =
        storage.read<Map<String, dynamic>>("respondentData");
    apiUrl.value = storage.read<String>('apiUrl') ?? '';
    respondentData = respondentFromStorage ??
        {'id': 'unknown', 'username': _tokenProvider.getUsername()};
    initialSurveyQuestions =
        (storage.read<List<dynamic>>('initialSurvey') ?? []).map((e) {
      if (e.runtimeType != InitialSurveyQuestion) {
        return InitialSurveyQuestion.fromJson(e);
      }
      return e as InitialSurveyQuestion;
    }).toList();
  }

  String getLabelFormIndex(int index) {
    if (index == 0){
      return getAppLocalizations().apiUrl;
    }
  
    if (index == 1) {
      return AppLocalizations.of(Get.context!)!.username;
    }

    return respondentData.keys.toList()[index];
  }

  String getValueForIndex(String question) {
    if (question == getAppLocalizations().apiUrl) {
      return apiUrl.value;
    }

    if (question.toLowerCase() ==
        getAppLocalizations().username.toLowerCase()) {
      return respondentData['username'];
    }

    final actualQuestion =
        initialSurveyQuestions.firstWhereOrNull((q) => q.content == question);

    if (actualQuestion == null) {
      return '';
    }

    final selectedOption = actualQuestion.options
        .firstWhereOrNull((o) => o.id == respondentData[question]);

    if (selectedOption == null) {
      return '';
    }

    return selectedOption.content;
  }
}
