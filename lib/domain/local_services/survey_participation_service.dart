import 'package:survey_frontend/domain/models/survey_participation_dto.dart';

abstract class SurveyParticipationService{
  Future<List<SurveyParticipationDto>> getAllParticipates();
  Future<void> addParticipation(SurveyParticipationDto dto);
}