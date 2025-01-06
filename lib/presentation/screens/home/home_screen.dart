import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/home_controller.dart';
import 'package:survey_frontend/presentation/functions/ask_for_permissions.dart';
import 'package:survey_frontend/presentation/screens/home/widgets/survey_tile.dart';
import 'package:survey_frontend/presentation/screens/home/widgets/time_circle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends GetView<HomeController> implements RouteAware {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    askForPermissions();
    controller.listenToNotifications();
    controller.refreshData();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/profile_circle.svg',
            height: 24,
          ),
          onPressed: () {
            controller.openProfile();
          },
        ),
        centerTitle: true,
        title: const Text(
          'UrbEaT',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              controller.openSettings();
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.nextSurveyTime,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => TimeCircle(
                    time: controller.hoursLeft.value,
                    unit: AppLocalizations.of(context)!.hours,
                    timeUnit: 24)),
                const SizedBox(width: 40),
                Obx(() => TimeCircle(
                    time: controller.minutesLeft.value,
                    unit: AppLocalizations.of(context)!.minutes,
                    timeUnit: 60)),
              ],
            ),
            const SizedBox(height: 40),
            Expanded(child: _buildSurveyList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyList() {
    return Obx(() => RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            itemCount: controller.pendingSurveys.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: SurveyTile(
                    surveyShortInfo: controller.pendingSurveys[index],
                    onPressed: () {
                      controller.startCompletingSurvey(
                          controller.pendingSurveys[index].id);
                    }),
              );
            },
          ),
        ));
  }

  @override
  void didPop() {
    return;
  }

  @override
  void didPopNext() {
    return;
  }

  @override
  void didPush() {
    controller.refreshData();
  }

  @override
  void didPushNext() {
    controller.refreshData();
  }
}
