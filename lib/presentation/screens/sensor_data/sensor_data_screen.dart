import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/core/models/sensors_response.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/sensor_data_controller.dart';
import 'package:survey_frontend/presentation/screens/sensor_data/widgets/sensor_scanning_circle.dart';
import 'package:survey_frontend/presentation/screens/sensor_data/widgets/sensor_scanning_error_circle.dart';
import 'package:survey_frontend/presentation/screens/sensor_data/widgets/sensor_scanning_result_circle.dart';

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
                    Navigator.pop(context);
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
                      child: SensorScanningResultCircle(
                        sensorResponse:
                            SensorsResponse(temperature: 21.5, humidity: 80.0)
                                .obs,
                      ))
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
                        onPressed: () {},
                        child: Text(getAppLocalizations().sensorDataHistory))),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(getAppLocalizations().saveReading),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
