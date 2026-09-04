import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/stress_level_service.dart';
import 'package:survey_frontend/domain/models/stress_level_dto.dart';

class StressLevelServiceImpl extends APIServiceBase
    implements StressLevelService {
  StressLevelServiceImpl(super.dio);

  @override
  Future<APIResponse<List<StressLevelDto>>> getStressLevels() =>
      get<List<StressLevelDto>>(
          '/api/stresslevels',
          (dynamic items) => items
              .map<StressLevelDto>((e) => StressLevelDto.fromJson(e))
              .toList());
}
