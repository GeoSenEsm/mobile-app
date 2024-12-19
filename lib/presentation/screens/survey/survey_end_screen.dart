import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/survey_end_controller.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/next_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SurveyEndScreen extends GetView<SurveyEndController> {
  const SurveyEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.readGetArgs();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Center(
              child: Text(
                AppLocalizations.of(context)!.endSurveyQuestion,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const Spacer(),
            NextButton(
                nextAction: controller.endSurvey,
                text: AppLocalizations.of(context)!.finish),
          ],
        ),
      ),
    );
  }
}
