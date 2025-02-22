import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:survey_frontend/core/models/sensors_response.dart';

class SensorScanningResultCircle extends StatelessWidget {
  final Rx<SensorsResponse?> sensorResponse;

  const SensorScanningResultCircle({super.key, required this.sensorResponse});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor
      ),
      child: Obx(() {
        if (sensorResponse.value == null) return const SizedBox();
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                '${sensorResponse.value!.temperature.toStringAsFixed(1)} °C',
                style: const TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 150,
              child: Text(
                '${sensorResponse.value!.humidity.toStringAsFixed(0)}%',
                style: const TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              
            ),
          ],
        ));
      }),
    );
  }
}
