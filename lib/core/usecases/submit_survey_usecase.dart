import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/domain/external_services/survey_response_service.dart';
import 'package:survey_frontend/domain/models/create_survey_response_dto.dart';
import 'package:survey_frontend/domain/models/survey_participation_dto.dart';

abstract class SubmitSurveyUsecase{
  Future<SurveyParticipationDto?> submitSurvey(CreateSurveyResponseDto dto);
  Future<bool> submitAllLocallySaved();
}

class SubmitSurveyUsecaseImpl implements SubmitSurveyUsecase{
  final SurveyResponseService _surveyResponseService;
  final Connectivity _connectivity;
  final GetStorage _storage;

  SubmitSurveyUsecaseImpl(this._surveyResponseService, this._connectivity, this._storage);

  @override
  Future<SurveyParticipationDto?> submitSurvey(CreateSurveyResponseDto dto) async {
    if (!await _hasInternetConnection()){
      await _saveLocally(dto);
      return null;
    }

    return await _submitToServer(dto);
  }

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.ethernet)
    || connectivityResult.contains(ConnectivityResult.wifi)
    || connectivityResult.contains(ConnectivityResult.mobile);
  }

  Future<void> _saveLocally(CreateSurveyResponseDto dto) async {
    final surveys  = await _getCurrentlySavedResponses();
    surveys.add(dto);
    await _storage.write('savedResponses', surveys);
  }

  Future<List<CreateSurveyResponseDto>> _getCurrentlySavedResponses(){
    final result = _storage.read<List<dynamic>>('savedResponses') ?? [];

    return Future.value(result.map((e){
      if (e.runtimeType == CreateSurveyResponseDto){
        return e as CreateSurveyResponseDto;
      }

      return CreateSurveyResponseDto.fromJson(e);
    }).toList());
  }

  Future<SurveyParticipationDto?> _submitToServer(CreateSurveyResponseDto dto) async {
    final apiResponse = await _surveyResponseService.submitResponse(dto);
    if (apiResponse.statusCode == 201){
      return apiResponse.body;
    }

    await _saveLocally(dto);
    return null;
  }

  @override
  Future<bool> submitAllLocallySaved() async {
    if (!await _hasInternetConnection()){
      return false;
    }

    final currentlySaved = await _getCurrentlySavedResponses();

    if (currentlySaved.isEmpty){
      return  true;
    }

    final apiResponse = await _surveyResponseService.submitResponses(currentlySaved);
    if (apiResponse.statusCode == 201){
      await _storage.remove('savedResponses');
      return true;
    }

    return false;
  }
}