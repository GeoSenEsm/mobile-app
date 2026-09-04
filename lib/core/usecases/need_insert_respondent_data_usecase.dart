import 'package:survey_frontend/core/models/need_insert_respondent_data_result.dart';

abstract class NeedInsertRespondentDataUseCase{
  Future<NeedInsertRespondentDataResult> needInsertRespondentData();
  Future<void> update(String respondentId);
}