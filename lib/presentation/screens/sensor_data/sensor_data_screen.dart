import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/sensor_data_controller.dart';
import 'package:survey_frontend/presentation/screens/sensor_data/widgets/sensor_scanning_circle.dart';
import 'package:survey_frontend/presentation/screens/sensor_data/widgets/sensor_scanning_error_circle.dart';
import 'package:survey_frontend/presentation/screens/sensor_data/widgets/sensor_scanning_result_circle.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Obx(_circleBuilder))
                ],
              ),
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

  Widget _circleBuilder() {
    if (controller.state.value == SensorDataState.scanning ||
        controller.state.value == SensorDataState.initial) {
      return const SensorScanningCircle();
    }

    if (controller.state.value == SensorDataState.bluetoothTurnedOff) {
      return _buildErrorCircle(getAppLocalizations().bluetoothTurnedOff);
    }

    if (controller.state.value == SensorDataState.sensorNotFound) {
      return _buildErrorCircle(getAppLocalizations().sensorNotFound);
    }

    if (controller.state.value == SensorDataState.error) {
      return _buildErrorCircle(getAppLocalizations().error);
    }

    if (controller.state.value == SensorDataState.sensorNotSpecified) {
      return _buildErrorCircle(getAppLocalizations().sensorNotSpecified);
    }

    return SensorScanningResultCircle(
        sensorResponse: controller.sensorResponse);
  }

  Widget _buildErrorCircle(String errorMessage) {
    return SensorScanningErrorCircle(
      errorMessage: errorMessage,
      onRetry: controller.startScanning,
    );
  }

  Widget _buildSendReadingButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.sensorResponse.value == null
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
