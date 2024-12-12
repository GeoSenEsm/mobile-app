import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:survey_frontend/core/usecases/need_insert_respondent_data_usecase.dart';
import 'package:survey_frontend/core/usecases/need_insert_respondent_data_usecase_impl.dart';
import 'package:survey_frontend/core/usecases/read_sensors_data_usecase.dart';
import 'package:survey_frontend/core/usecases/send_sensors_data_usecase.dart';
import 'package:survey_frontend/core/usecases/survey_notification_usecase.dart';
import 'package:survey_frontend/core/usecases/token_provider_impl.dart';
import 'package:survey_frontend/core/usecases/token_validity_checker_impl.dart';
import 'package:survey_frontend/data/datasources/initial_survey_service_impl.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/datasources/local/survey_participation_service_impl.dart';
import 'package:survey_frontend/data/datasources/location_service_impl.dart';
import 'package:survey_frontend/data/datasources/login_service_impl.dart';
import 'package:survey_frontend/data/datasources/respondent_data_service_impl.dart';
import 'package:survey_frontend/data/datasources/sensors_data_service_impl.dart';
import 'package:survey_frontend/data/datasources/survey_service_impl.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:survey_frontend/domain/external_services/initial_survey_service.dart';
import 'package:survey_frontend/domain/external_services/location_service.dart';
import 'package:survey_frontend/domain/external_services/login_service.dart';
import 'package:survey_frontend/domain/external_services/respondent_date_service.dart';
import 'package:survey_frontend/domain/external_services/sensors_data_service.dart';
import 'package:survey_frontend/domain/external_services/survey_service.dart';
import 'package:survey_frontend/domain/local_services/survey_participation_service.dart';
import 'package:survey_frontend/domain/usecases/token_provider.dart';
import 'package:survey_frontend/domain/usecases/token_validity_checker.dart';
import 'package:survey_frontend/main.dart';
import 'package:survey_frontend/presentation/bindings/bindings_options.dart';
import 'package:survey_frontend/presentation/controllers/archived_surveys_controller.dart';
import 'package:survey_frontend/presentation/controllers/respondent_data_controller.dart';
import 'package:survey_frontend/presentation/controllers/survey_question_controller.dart';

class InitialBindings extends Bindings {
  static bool _registered = false;

  InitialBindings();

  @override
  void dependencies() {
    if (_registered) {
      return;
    }
    _registered = true;
    final location = Location();
    try{
      location.enableBackgroundMode(enable: true);
    } catch (e){
      //ignore for now
    }
    Get.put(location);
    final storage = GetStorage();
    Get.put(storage);
    Get.put(_getDio(storage));
    Get.put<LoginService>(LoginServiceImpl(Get.find()));
    Get.lazyPut(() => RespondentDataController());
    Get.lazyPut(() => ArchivedSurveysController());
    Get.create<SurveyService>(() => SurveyServiceImpl(Get.find()));
    Get.create<SurveyQuestionController>(() => SurveyQuestionController());

    TokenProvider tp = TokenProviderImpl(Get.find());
    Get.put<TokenProvider>(tp);
    Get.put<TokenProvider?>(tp);
    Get.put<InitialSurveyService>(
        InitialSurveyServiceImpl(Get.find(), tokenProvider: Get.find()));
    Get.lazyPut<SurveyParticipationService>(
        () => SurveyParticipationServiceImpl(Get.find()));
    Get.put<NeedInsertRespondentDataUseCase>(
        NeedInsertRespondentDataUseCaseImpl(Get.find(), Get.find()));
    Get.put<TokenValidityChecker>(TokenValidityCheckerImpl());
    Get.lazyPut<RespondentDataService>(() => RespondentDataServiceImpl(
        Get.find(),
        tokenProvider: Get.find<TokenProvider>()));
    Get.put(DatabaseHelper());
    Get.put<SurveyNotificationUseCase>(SurveyNotificationUseCaseImpl(Get.find()));
    Get.put<SensorsDataService>(
        SensorsDataServiceImpl(Get.find(), tokenProvider: Get.find()));
    Get.put<SendSensorsDataUsecase>(
        SendSensorsDataUsecaseImpl(Get.find(), Get.find()));
    Get.put<ReadSensorsDataUsecase>(ReadXiaomiSensorsDataUsecase(),
        tag: SensorKind.xiaomi);
    Get.put<LocalizationService>(LocalizationServiceImpl(Get.find(), tokenProvider: Get.find<TokenProvider>()));

  }

  Dio _getDio(GetStorage storage) {
    var dio = Dio();
    final apiUrl = storage.read<String>('apiUrl');
    if (apiUrl != null) {
      dio.options.baseUrl = apiUrl; 
    }
    dio.options.headers["Accept-Lang"] = StaticVariables.lang;
    return dio;
  }
}
