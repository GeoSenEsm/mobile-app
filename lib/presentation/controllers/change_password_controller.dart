import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/domain/external_services/change_password_service.dart';
import 'package:survey_frontend/domain/models/change_password_dto.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class ChangePasswordController extends ControllerBase {
  final RxString currentPassword = ''.obs;
  final RxString newPassword = ''.obs;
  final RxString retypePassword = ''.obs;
  final formKey = GlobalKey<FormState>();
  final ChangePasswordService _service;
  bool isBusy = false;
  bool invalidCredentials = false;

  ChangePasswordController(this._service);

  void save() async {
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

      final apiResult = await _service.changePassword(ChangePasswordDto(
          oldPassword: currentPassword.value, newPassword: newPassword.value));

      if (apiResult.statusCode == 401){
        handleInvalidCurrentPassword();
        return;
      }

      if (apiResult.statusCode == 200){
        Get.toNamed(Routes.changePasswordConfirmation);
        return;
      }

      handleSomethingWentWrong(apiResult.error);
    } catch (e) {
      handleSomethingWentWrong(e);
    } finally {
      isBusy = false;
    }
  }

  void handleInvalidCurrentPassword(){
    try{
      invalidCredentials = true;
      formKey.currentState!.validate();
      Get.focusScope!.unfocus();
    } finally{
      invalidCredentials = false;
    }
  }

  void clearData() {
    currentPassword.value = '';
    newPassword.value = '';
    retypePassword.value = '';
  }

  String? validateCurrentPassword(String? value) {
    if (invalidCredentials){
      return getAppLocalizations().invalidCredentials;
    }

    if (value?.isEmpty ?? true) {
      return getAppLocalizations().currentPasswordMustNotBeEmpty;
    }

    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.length < 12) {
      return getAppLocalizations().minNewPasswordLenError;
    }

    return null;
  }

  String? validateRetypePassword(String? value) {
    if (value != newPassword.value) {
      return getAppLocalizations().retypePasswordMustBeEqualToNewPassword;
    }

    return null;
  }
}
