import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/login_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/widgets/app_logo.dart';
import 'package:survey_frontend/presentation/widgets/password_form_field.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(),
              Flexible(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.apiUrl,
                        ),
                        validator: controller.apiUrlValidator,
                        onChanged: (value) {
                          controller.apiUrl = value;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.username,
                        ),
                        validator: controller.usernameValidator,
                        onChanged: (value) {
                          controller.model.value.username = value;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      PasswordFormField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.password,
                        ),
                        validator: controller.passwordValidator,
                        onChanged: (value) {
                          controller.model.value.password = value;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.login,
                          child: Text(AppLocalizations.of(context)!.login),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
