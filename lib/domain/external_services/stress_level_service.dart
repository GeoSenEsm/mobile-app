import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/models/stress_level_dto.dart';

abstract class StressLevelService{
  Future<APIResponse<List<StressLevelDto>>> getStressLevels();
}