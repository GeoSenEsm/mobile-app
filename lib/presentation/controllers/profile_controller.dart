import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/domain/models/initial_survey_question.dart';
import 'package:survey_frontend/domain/usecases/token_provider.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/functions/formatters.dart';

const _metadataKeys = [
  'apiUrl',
  'username',
  'surveyStartDate',
  'surveyEndDate',
  'timeZone',
];

class ProfileController extends ControllerBase {
  late Map<String, dynamic> respondentData;
  late List<InitialSurveyQuestion> initialSurveyQuestions;
  final TokenProvider _tokenProvider;
  final RxString apiUrl = ''.obs;
  late final List<String> _visibleMetadataKeys;

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

    _visibleMetadataKeys = _metadataKeys
        .where((key) => key == 'apiUrl' || key == 'username' || _isSet(key))
        .toList();
  }

  bool _isSet(String metadataKey) {
    final value = respondentData[metadataKey];
    return value != null && value.toString().trim().isNotEmpty;
  }

  int get itemCount => _visibleMetadataKeys.length + initialSurveyQuestions.length;

  String getLabelFormIndex(int index) {
    if (index < _visibleMetadataKeys.length) {
      return _metadataLabel(_visibleMetadataKeys[index]);
    }

    return initialSurveyQuestions[index - _visibleMetadataKeys.length].content;
  }

  String getValueForIndex(int index) {
    if (index < _visibleMetadataKeys.length) {
      return _metadataValue(_visibleMetadataKeys[index]);
    }

    final question =
        initialSurveyQuestions[index - _visibleMetadataKeys.length];
    final selectedOption = question.options
        .firstWhereOrNull((o) => o.id == respondentData[question.content]);

    return selectedOption?.content ?? '';
  }

  String _metadataLabel(String key) {
    final localizations = getAppLocalizations();
    switch (key) {
      case 'apiUrl':
        return localizations.apiUrl;
      case 'username':
        return localizations.username;
      case 'surveyStartDate':
        return localizations.surveyStartDate;
      case 'surveyEndDate':
        return localizations.surveyEndDate;
      case 'timeZone':
        return localizations.timeZone;
    }
    throw StateError('Unknown metadata key: $key');
  }

  String _metadataValue(String key) {
    switch (key) {
      case 'apiUrl':
        return apiUrl.value;
      case 'username':
        return respondentData['username'];
      case 'surveyStartDate':
        return dateOnlyShortFormat(
            DateTime.parse(respondentData['surveyStartDate']));
      case 'surveyEndDate':
        return dateOnlyShortFormat(
            DateTime.parse(respondentData['surveyEndDate']));
      case 'timeZone':
        return respondentData['timeZone'];
    }
    throw StateError('Unknown metadata key: $key');
  }
}
