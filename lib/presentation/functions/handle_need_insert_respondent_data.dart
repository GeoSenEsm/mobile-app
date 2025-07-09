import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/models/need_insert_respondent_data_result.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

void handle(NeedInsertRespondentDataResult result) {
  switch (result) {
    case NeedInsertRespondentDataResult.need:
      goToNamedPrivacySave(Routes.welcome);
      break;
    case NeedInsertRespondentDataResult.noNeed:
      goToNamedPrivacySave(Routes.home);
      break;
    case NeedInsertRespondentDataResult.error:
      Get.defaultDialog(
          title: AppLocalizations.of(Get.context!)!.error,
          middleText: AppLocalizations.of(Get.context!)!.error,
          confirm: ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Ok"),
          ));
      break;
  }
}

void goToNamedPrivacySave(String path) async {
  final storage = GetStorage();
  final privacyPolicyAccepted =
      storage.read<bool>('privacyPolicyAccepted') ?? false;
  if (privacyPolicyAccepted) {
    Get.toNamed(path);
    return;
  }

  Get.toNamed(Routes.acceptPrivacyPolicy, arguments: {'nextPage': path});
}
