import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/notifications_settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationsSettingsScreen extends GetView<NotificationsSettingsController>{
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadSettings();
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
                  AppLocalizations.of(context)!.notifications,
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
                            AppLocalizations.of(context)!.notifyMeAboutSurveys,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Switch(
                              value: controller.notifyAboutSurveys.value,
                              onChanged: (v) {
                                controller.notifyAboutSurveys.value = v;
                              })
                        ],
                      ),
                    )),
                const SizedBox(height: 10),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppStyles.backgroundSecondary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5)
            )
          ]
        ),
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