import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/models/need_insert_respondent_data_result.dart';
import 'package:survey_frontend/core/usecases/need_insert_respondent_data_usecase.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/initial_survey_service.dart';
import 'package:survey_frontend/domain/external_services/respondent_group_service.dart';

class NeedInsertRespondentDataUseCaseImpl
    implements NeedInsertRespondentDataUseCase {
  final InitialSurveyService _respondentDataService;
  final GetStorage _storage;
  final RespondentGroupService _respondentGroupService;

  NeedInsertRespondentDataUseCaseImpl(
      this._respondentDataService, this._storage, this._respondentGroupService);

  @override
  Future<NeedInsertRespondentDataResult> needInsertRespondentData() async {
    var respondentData = _storage.read("respondentData");
    bool loggedBefore = _storage.read("loggedBefore") ?? false;

    if (respondentData != null) {
      await update(respondentData['id']);
      return NeedInsertRespondentDataResult.noNeed;
    }

    var respondentDataApiResponse =
        await _respondentDataService.getMyResponse();
    final surveyResult = await _respondentDataService.getInitialSurvey();

    if (respondentDataApiResponse.statusCode == 200 &&
        surveyResult.statusCode == 200) {
      await _storage.write('initialSurvey', surveyResult.body!);
      await _storage.write("respondentData", respondentDataApiResponse.body);
      await _trySaveResopndentsGroups(respondentDataApiResponse.body!['id']);
      return NeedInsertRespondentDataResult.noNeed;
    }

    if (loggedBefore) {
      return NeedInsertRespondentDataResult.noNeed;
    }

    if (respondentDataApiResponse.error != null ||
        (respondentDataApiResponse.statusCode != 200 &&
            respondentDataApiResponse.statusCode != 404)) {
      return NeedInsertRespondentDataResult.error;
    }

    if (surveyResult.error != null ||
        (surveyResult.statusCode != 200 && surveyResult.statusCode != 404)) {
      return NeedInsertRespondentDataResult.error;
    }

    if (surveyResult.statusCode == 404 || surveyResult.body!.isEmpty) {
      return NeedInsertRespondentDataResult.noNeed;
    }

    return NeedInsertRespondentDataResult.need;
  }

  Future<void> _trySaveResopndentsGroups(String respondentId) async {
    final groupsResult =
        await _respondentGroupService.getAllForRespondent(respondentId);

    if (groupsResult.statusCode == 200) {
      await _storage.write('groups', groupsResult.body);
    }
  }

  @override
  Future<void> update(String respondentId) async {
    final results = await Future.wait([
      _trySaveResopndentsGroups(respondentId),
      _respondentDataService.getMyResponse()
    ]);
    final respondentDataResult =
        results[1] as APIResponse<Map<String, dynamic>>;

    if (respondentDataResult.statusCode == 200) {
      await _storage.write('respondentData', respondentDataResult.body);
    }
  }
}
