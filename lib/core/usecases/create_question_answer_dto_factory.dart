import 'package:survey_frontend/domain/models/create_question_answer_dto.dart';
import 'package:survey_frontend/domain/models/create_selected_option_dto.dart';
import 'package:survey_frontend/domain/models/question_type.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';

abstract class CreateQuestionAnswerDtoFactory {
  CreateQuestionAnswerDto getDto(Question question);
}

class CreateQuestionAnswerDtoFactoryImpl
    implements CreateQuestionAnswerDtoFactory {
  @override
  CreateQuestionAnswerDto getDto(Question question) {
    if (question.questionType == QuestionType.singleChoiceText ||
        question.questionType == QuestionType.imageChoice) {
      return CreateQuestionAnswerDto(
          questionId: question.id,
          selectedOptions: [CreateSelectedOptionDto()]);
    }
    if (question.questionType == QuestionType.multipleChoiceText) {
      return CreateQuestionAnswerDto(
        questionId: question.id,
        selectedOptions: [],
      );
    }

    return CreateQuestionAnswerDto(questionId: question.id);
  }
}
