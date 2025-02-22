import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/logout_confirmation_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LogoutConfirmationScreen extends GetView<LogoutConfirmationController> {
  final LogoutConfirmationController _controller;

  LogoutConfirmationScreen({super.key}) : _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundSecondary,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 60, 15.0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: AppStyles.onBackgroundSecondary,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Icon(Icons.question_mark),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppLocalizations.of(context)!.logountConfirmationQuestion,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Obx(
                      () {
                        if (_controller.isBusy.value) {
                          return Column(
                            children: [
                              CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }
                        return const SizedBox(height: 0, width: 0);
                      },
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: _controller.logOut,
                          child: Text(AppLocalizations.of(context)!.yes)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            if (!_controller.isBusy.value){
                              Get.back();
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.no)),
                    )
                  ],
                ),
              ),
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }
}
