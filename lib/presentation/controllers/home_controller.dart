import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/usecases/create_question_answer_dto_factory.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/respondent_group_service.dart';
import 'package:survey_frontend/domain/external_services/short_survey_service.dart';
import 'package:survey_frontend/domain/external_services/survey_service.dart';
import 'package:survey_frontend/domain/models/create_question_answer_dto.dart';
import 'package:survey_frontend/domain/models/create_survey_resopnse_dto.dart';
import 'package:survey_frontend/domain/models/question_type.dart';
import 'package:survey_frontend/domain/models/short_survey_dto.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/controllers/survey_question_controller.dart';

class HomeController extends ControllerBase {
  final ShortSurveyService _homeService;
  final SurveyService _surveyService;
  final CreateQuestionAnswerDtoFactory _createQuestionAnswerDtoFactory;
  final RespondentGroupService _respondentGroupService;
  final GetStorage _storage;
  RxList<ShortSurveyDto> pendingSurveys = <ShortSurveyDto>[].obs;
  final RxInt hours = 5.obs;
  final RxInt minutes = 13.obs;
  bool _isBusy = false;

  HomeController(this._homeService, this._surveyService, 
  this._createQuestionAnswerDtoFactory,
  this._respondentGroupService,
  this._storage) {
    _loadShortSurveys();
  }

  Future<void> _loadShortSurveys() async {
    if (_isBusy) {
      return;
    }

    try {
      _isBusy = true;
      pendingSurveys.clear();
      APIResponse<List<ShortSurveyDto>> response =
          await _homeService.getShortSurvey();
      if (response.error != null || response.statusCode != 200) {
        await handleSomethingWentWrong(null);
        return;
      }
      pendingSurveys.addAll(response.body!);
    } catch (e) {
      //TODO: log the exception
      await popup(
          "Błąd", "Nie udało się załądować ankiet. Spróbuj ponownie później.");
    } finally {
      _isBusy = false;
    }
  }

  void startCompletingSurvey(String surveyId) async {
    if (_isBusy) {
      return;
    }

    try {
      _isBusy = true;
      //TODO: run those futures at once
      SurveyDto? survey = await _loadSurvey(surveyId);
      var respondentGroups = await _getGroupsIds();

      if (survey == null || respondentGroups == null) {
        await popup("Błąd", "Nie udało się załadować wybranej ankiety");
        return;
      }
      final questions = _getQuestionsFromSurvey(survey);
      final responseModel = _prepareResponseModel(questions, survey.id);
      await Get.toNamed("/surveystart", arguments: {
        "survey": survey,
        "questions": questions,
        "responseModel": responseModel,
        "groups": respondentGroups
      });
    } catch (e) {
      await popup("Błąd", "Nie udało się załadować wybranej ankiety");
    } finally {
      _isBusy = false;
    }
  }

  Future<SurveyDto?> _loadSurvey(String surveyId) async {
    APIResponse<SurveyDto> response = await _surveyService.getSurvey(surveyId);
    if (response.error != null || response.body == null) {
      return null;
    }
    return response.body!;
  }

  
  Future<List<String>?> _getGroupsIds() async{
    var respondentData = _storage.read<Map<String, dynamic>>("respondentData")!;
    var groupsResponse = await _respondentGroupService.getAllForRespndent(respondentData["id"]);

    return groupsResponse.body?.map((e) => (e.id)).toList();
  }

  List<QuestionWithSection> _getQuestionsFromSurvey(SurveyDto surveyObj) {
    return surveyObj.sections
        .expand((section) => section.questions.map((question) =>
            QuestionWithSection(question: question, section: section)))
        .toList();
  }

  CreateSurveyResponseDto _prepareResponseModel(List<QuestionWithSection> questions, String surveyId){
    final questionAnswerDtos = questions
    .map((q) => _createQuestionAnswerDtoFactory.getDto(q.question.questionType))
    .toList();

    return CreateSurveyResponseDto(surveyId: surveyId, answers: questionAnswerDtos);
  } 
}

class SurveyShortInfo {
  final String name;
  final String id;
  SurveyShortInfo({required this.name, required this.id});
}

class QuestionWithSection {
  final Question question;
  final Section section;
  QuestionWithSection({required this.question, required this.section});

  get id => question.id;

  bool sectionOK() {
    return true;
    if (section.visibility == "always") {
      return true;
    }
    //TODO check if user is in "group_specific"
    return false;
  }
}
