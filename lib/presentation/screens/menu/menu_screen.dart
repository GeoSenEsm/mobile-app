import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/menu_controller.dart';
import 'package:survey_frontend/presentation/screens/menu/widgets/nav_item.dart';

class MenuScreen extends GetView<ManuController> {
  const MenuScreen({super.key});
  final Color settingsBackgroundColor =
      const Color.fromARGB(173, 214, 236, 154);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            decoration: BoxDecoration(
              color: settingsBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.menu,
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
              color: settingsBackgroundColor,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    NavItem(
                        icon: Icons.calendar_month_outlined,
                        label: getAppLocalizations().calendar,
                        onTap: controller.calendar),
                    NavItem(
                        icon: Icons.wb_sunny_outlined,
                        label: getAppLocalizations().sensorData,
                        onTap: controller.sensorData),
                    NavItem(
                        icon: Icons.manage_search,
                        label: getAppLocalizations().sensorHistory,
                        onTap: controller.sensorHistory),
                    NavItem(
                        icon: Icons.location_on_outlined,
                        label: getAppLocalizations().map,
                        onTap: controller.map),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.appSettings,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    NavItem(
                      icon: Icons.shield_outlined,
                      label: AppLocalizations.of(context)!.privacySettings,
                      onTap: controller.privacySettings,
                      iconColor: Colors.black,
                    ),
                    NavItem(
                      icon: Icons.notifications_outlined,
                      label: AppLocalizations.of(context)!.notifications,
                      onTap: controller.notifications,
                      iconColor: Colors.black,
                    ),
                    NavItem(
                      icon: Icons.thermostat,
                      label: AppLocalizations.of(context)!.editSensor,
                      onTap: controller.editSensor,
                      iconColor: Colors.black,
                    ),
                    NavItem(
                      icon: Icons.key,
                      label: AppLocalizations.of(context)!.changePassword,
                      onTap: controller.changePassword,
                      iconColor: Colors.black,
                    ),
                    NavItem(
                      icon: Icons.lock_open,
                      label: AppLocalizations.of(context)!.logout,
                      onTap: controller.logout,
                      iconColor: Colors.black,
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.help,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    NavItem(
                      icon: Icons.phone,
                      label: AppLocalizations.of(context)!.contact,
                      onTap: controller.contact,
                      iconColor: Colors.black,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
