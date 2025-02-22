import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/change_password_controller.dart';
import 'package:survey_frontend/presentation/widgets/password_form_field.dart';

class ChangePasswordScreen extends GetView<ChangePasswordController>{
  const ChangePasswordScreen({super.key});


  @override
  Widget build(BuildContext context) {
    controller.clearData();
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 60,
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppStyles.backgroundSecondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getAppLocalizations().changePassword,
                  textScaler: const TextScaler.linear(1),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 24),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Form
          (
            key: controller.formKey,
            child: Expanded(
              child: Container(
                color: AppStyles.backgroundSecondary,
                child:SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      PasswordFormField(
                        validator: controller.validateCurrentPassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: getAppLocalizations().currentPassword,
                        ),
                        initialValue: controller.currentPassword.value,
                        onChanged: (v){
                          controller.currentPassword.value = v;
                        },
                      ),
                      const SizedBox(height: 20,),
                      PasswordFormField(
                        validator: controller.validateNewPassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: getAppLocalizations().newPassword,
                        ),
                        initialValue: controller.newPassword.value,
                        onChanged: (v){
                          controller.newPassword.value = v;
                        },
                      ),
                      const SizedBox(height: 20,),
                      PasswordFormField(
                        validator: controller.validateRetypePassword,
                        decoration: InputDecoration(
                           filled: true,
                          fillColor: Colors.white,
                          labelText: getAppLocalizations().retypePassword,
                        ),
                        initialValue: controller.retypePassword.value,
                        onChanged: (v){
                          controller.retypePassword.value = v;
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration:
            BoxDecoration(color: AppStyles.backgroundSecondary, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ]),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: ElevatedButton(
            onPressed: controller.save,
            child: Text(getAppLocalizations().save),
          ),
        ),
      )
    );
  }

}