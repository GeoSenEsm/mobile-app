import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/short_survey_service.dart';
import 'package:survey_frontend/domain/models/survey_with_time_slots.dart';

class ShortSurveyServiceImpl extends APIServiceBase
    implements ShortSurveyService {
  final GetStorage _storage;
  ShortSurveyServiceImpl(this._storage, super.dio,
      {required super.tokenProvider});

  @override
  Future<APIResponse<List<SurveyWithTimeSlots>>> getSurveysWithTimeSlots() =>
      get<List<SurveyWithTimeSlots>>(
          '/api/surveys/allwithtimeslots',
          (dynamic items) => items
              .map<SurveyWithTimeSlots>((e) => SurveyWithTimeSlots.fromJson(e))
              .toList(),
          headers: {
            'maxRowVersion': _storage.read<int>('surveysRowVersion') ?? 0
          });
}
