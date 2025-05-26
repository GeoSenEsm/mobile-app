import 'dart:core';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/usecases/need_insert_respondent_data_usecase.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/ip_localization_country_code_service.dart';
import 'package:survey_frontend/domain/external_services/login_service.dart';
import 'package:survey_frontend/domain/models/login_dto.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/functions/handle_need_insert_respondent_data.dart';
import 'package:http/http.dart' as http;

class LoginController extends ControllerBase {
  final Rx<LoginDto> model = LoginDto().obs;
  final formKey = GlobalKey<FormState>();
  final LoginService _loginService;
  final NeedInsertRespondentDataUseCase _needInsertRespondentDataUseCase;
  final GetStorage _storage;
  String? apiUrl;
  late RegExp apiUrlRegex = RegExp(
      r'(https:\/\/)?(www\\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)(:\d+)?');
  bool isBusy = false;
  bool _alwaysValidateInvalidCredentials = false;
  final Dio _dio;
  final IpLocalizationCountryCodeService _ipLocalizationCountryCodeService;

  LoginController(this._loginService, this._storage,
      this._needInsertRespondentDataUseCase, this._dio,
      this._ipLocalizationCountryCodeService) {
    if (kDebugMode) {
      apiUrlRegex = RegExp(
          r'(https?)?:\/\/(www\\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)(:\d+)?');
    }
  }

  void login() async {
    if (isBusy) {
      return;
    }

    try {
      isBusy = true;
      final isValid = formKey.currentState!.validate();
      Get.focusScope!.unfocus();

      if (!isValid) {
        return;
      }

      formKey.currentState!.save();

      if (!await hasInternetConnection()) {
        return;
      }

      if (!await _isUrlAllowed()){
        return;
      }

      _saveUrl();
      var apiResponse = await _loginService.login(model.value);
      await handleAPIResponse(apiResponse);
    } catch (e) {
      await handleSomethingWentWrong(e);
    } finally {
      isBusy = false;
    }
  }

  Future<bool> _isUrlAllowed() async {
    final myLocalizationResponse = await _ipLocalizationCountryCodeService.getIpLoclization(null);
    if (myLocalizationResponse.error != null || myLocalizationResponse.statusCode != 200
       || myLocalizationResponse.body!.status != 'success'){
      final message = getAppLocalizations().weWereUnableToDetermineTheServerAvailibility;
      await popup('', message);
      return false;
    }

    if (myLocalizationResponse.body!.countryCode != 'CN'){
      return true;
    }

    var domainOrIp = _extractDomainOrIp(apiUrl!);
    var serverLocalizationResponse = await _ipLocalizationCountryCodeService.getIpLoclization(domainOrIp);

    if (serverLocalizationResponse.statusCode == 200 && serverLocalizationResponse.body!.status != 'success'
        && domainOrIp.startsWith('www.')){
      domainOrIp = domainOrIp.substring(4);
      serverLocalizationResponse = await _ipLocalizationCountryCodeService.getIpLoclization(domainOrIp);
    }

    if (serverLocalizationResponse.error != null || serverLocalizationResponse.statusCode != 200
    || serverLocalizationResponse.body!.status != 'success'){
      final message = getAppLocalizations().weWereUnableToDetermineTheServerAvailibility;
      await popup('', message);
      return false;
    }

    if (serverLocalizationResponse.body!.countryCode != "CN"){
      final message = getAppLocalizations().theServerYouProvidedIsNotAllowedInYourLocation;
      await popup('', message);
      return false;
    }
    return true;
  }

  String _extractDomainOrIp(String input) {
  final uriString = input.contains('://') ? input : 'http://$input';

  Uri? uri;
  try {
    uri = Uri.parse(uriString);
  } catch (_) {
    return '';
  }

  String? host = uri.host;

  if (host == null || host.isEmpty) return '';

  final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');

  if (ipRegex.hasMatch(host)) {
    return host;
  } else {
    return host.startsWith('www.') ? host : 'www.$host';
  }
}


  String? passwordValidator(String? value) {
    const int maxPasswordLength = 255;

    if (_alwaysValidateInvalidCredentials) {
      return AppLocalizations.of(Get.context!)!.invalidCredentials;
    }

    if (value == null || value == '') {
      return AppLocalizations.of(Get.context!)!.passwordNotEmpty;
    }

    if (value.length > maxPasswordLength) {
      return AppLocalizations.of(Get.context!)!
          .passwordTooLong(maxPasswordLength);
    }

    return null;
  }

  String? usernameValidator(String? value) {
    const int maxUsernameLength = 255;

    if (_alwaysValidateInvalidCredentials) {
      return AppLocalizations.of(Get.context!)!.invalidCredentials;
    }

    if (value == null || value == '') {
      return AppLocalizations.of(Get.context!)!.usernameNotEmpty;
    }

    if (value.length > maxUsernameLength) {
      return AppLocalizations.of(Get.context!)!
          .usernameTooLong(maxUsernameLength);
    }

    return null;
  }

  String? apiUrlValidator(String? value) {
    if (value == null || value == '') {
      return AppLocalizations.of(Get.context!)!.apiUrlEmptyErrorMessage;
    }

    if (!apiUrlRegex.hasMatch(value)) {
      return AppLocalizations.of(Get.context!)!.apiUrlInvalidFormatErrorMessage;
    }

    return null;
  }

  Future handleAPIResponse(APIResponse<String> apiResponse) async {
    if (apiResponse.error?.runtimeType == DioException){
      popup(getAppLocalizations().error, getAppLocalizations().serverNotResponding);
      return;
    }

    if (apiResponse.error != null) {
      await handleSomethingWentWrong(apiResponse.error!);
      return;
    }

    if (apiResponse.statusCode == 401) {
      showInvalidCredentialsError();
      return;
    }

    if (apiResponse.statusCode != 200) {
      await handleSomethingWentWrong(getAppLocalizations().loginFailedServerRespondedWithStatusCode(apiResponse.statusCode!));
      return;
    }
    saveToken(apiResponse.body!);
    var needInsertRespondentDataRes =
        await _needInsertRespondentDataUseCase.needInsertRespondentData();
    handle(needInsertRespondentDataRes);
  }

  void showInvalidCredentialsError() {
    try {
      _alwaysValidateInvalidCredentials = true;
      formKey.currentState!.validate();
      Get.focusScope!.unfocus();
    } finally {
      _alwaysValidateInvalidCredentials = false;
    }
  }

  void saveToken(String token) {
    _storage.write('apiToken', token);
  }

  void _saveUrl() {
    if (!apiUrl!.startsWith('http')) {
      apiUrl = 'https://${apiUrl!}';
    }
    _storage.write('apiUrl', apiUrl);
    _dio.options.baseUrl = apiUrl!;
  }
}
