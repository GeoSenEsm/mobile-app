import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/privacy_settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/screens/privacy_policy/screens/privacy_policy_screen.dart';
import 'package:survey_frontend/presentation/widgets/time_picker.dart';

class PrivacySettingsScreen extends GetView<PrivacySettingsController> {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadPrivacySettings();
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
                  AppLocalizations.of(context)!.privacy,
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
          Expanded(
            child: Container(
              color: AppStyles.backgroundSecondary,
              child: Column(children: [
                Obx(() => Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.allowTrackLocation,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Switch(
                              value: controller.enableTrackingLocation.value,
                              onChanged: (v) {
                                controller.enableTrackingLocation.value = v;
                              })
                        ],
                      ),
                    )),
                const SizedBox(height: 10),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 10),
                Obx(() => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TimePicker(
                        onChange: (v) {
                          if (v != null) {
                            controller.setTimeFrom(v);
                          }
                        },
                        value: controller.timeFrom.value,
                        label: AppLocalizations.of(context)!.timeFrom,
                      ),
                    )),
                const SizedBox(
                  height: 30,
                ),
                Obx(() => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TimePicker(
                        onChange: (v) {
                          if (v != null) {
                            controller.setTimeTo(v);
                          }
                        },
                        value: controller.timeTo.value,
                        label: AppLocalizations.of(context)!.timeTo,
                      ),
                    )),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const PrivacyPolicyScreen()));
                  },
                  child: RichText(
                      text: TextSpan(
                    text: getAppLocalizations().openPrivacyPolicy,
                    style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  )),
                )
              ]),
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
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ),
      ),
    );
  }
}
