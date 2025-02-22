import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/profile_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  AppLocalizations.of(context)!.profile,
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
              child: ListView.builder(
                itemCount: controller.respondentData.length - 1,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: controller.getLabelFormIndex(index + 1),
                      labelStyle: const TextStyle(color: Colors.black),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    initialValue: controller.getValueForIndex(
                        controller.getLabelFormIndex(index + 1)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
