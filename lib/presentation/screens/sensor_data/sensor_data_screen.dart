import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/sensor_data_controller.dart';
import 'package:survey_frontend/presentation/screens/sensor_data/widgets/sensor_slot_circle.dart';

class SensorDataScreen extends GetView<SensorDataController> {
  const SensorDataScreen({super.key});

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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 22,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppStyles.backgroundSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Obx(_slotsBuilder),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStartScanningButton(),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: controller.sensorHistory,
                        child: Text(getAppLocalizations().sensorDataHistory))),
                const SizedBox(
                  height: 10,
                ),
                _buildSendReadingButton(),
              ],
            ),
          )),
    );
  }

  Widget _slotsBuilder() {
    if (controller.noSensorConfigured.value) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            getAppLocalizations().sensorNotSpecified,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final slot in controller.slots) ...[
            SensorSlotCircle(
              slot: slot,
              onRetry: () => controller.retrySlot(slot),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildStartScanningButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.noSensorConfigured.value
                ? null
                : controller.startScanning,
            child: Text(getAppLocalizations().startScanning),
          ),
        ));
  }

  Widget _buildSendReadingButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.sensorResponses.isEmpty ||
                    controller.sensorValues.isEmpty
                ? null
                : controller.sendSensorData,
            child: Obx(() {
              if (controller.isSendingData.value) {
                return const CircularProgressIndicator();
              }

              return Text(getAppLocalizations().saveReading);
            }),
          ),
        ));
  }
}
