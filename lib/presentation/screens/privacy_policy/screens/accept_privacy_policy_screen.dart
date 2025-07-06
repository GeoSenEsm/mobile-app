import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/accept_privacy_policy_controller.dart';
import 'package:survey_frontend/presentation/screens/privacy_policy/widgets/privacy_policy_content.dart';

class AcceptPrivacyPolicyScreen extends GetView<AcceptPrivacyPolicyController> {
  const AcceptPrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.readGetArguments();
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          PrivacyPolicyContent(
            onScrolledDown: () {
              controller.scrolled.value = true;
            },
          )
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() {
                  if (controller.scrolled.value || kDebugMode) {
                    return Row(
                      children: [
                        Flexible(
                          child: Text(
                            getAppLocalizations().iAcceptPrivacyPolicy,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        const Spacer(),
                        Checkbox(
                            value: controller.accepted.value,
                            onChanged: (v) {
                              if (v != null) {
                                controller.accepted.value = v;
                              }
                            })
                      ],
                    );
                  }
                  return Text(getAppLocalizations().scrollToTheVeryBottom);
                }),
                const SizedBox(
                  height: 10,
                ),
                Obx(() => ElevatedButton(
                    onPressed: (controller.scrolled.value &&
                                controller.accepted.value) ||
                            kDebugMode
                        ? controller.next
                        : null,
                    child: Text(getAppLocalizations().next)))
              ],
            )),
      ),
    );
  }
}
