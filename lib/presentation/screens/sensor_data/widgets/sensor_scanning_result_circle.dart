import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:survey_frontend/core/models/sensor_reading.dart';

class SensorScanningResultCircle extends StatelessWidget {
  final Rx<SensorReading?> sensorResponse;

  const SensorScanningResultCircle({super.key, required this.sensorResponse});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Theme.of(context).cardColor),
      child: Obx(() {
        if (sensorResponse.value == null) return const SizedBox();
        final values = sensorResponse.value!.values.entries.toList();
        return Center(
            child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: values.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final value = values[index];
            return Text(
              '${value.key}: ${_format(value.value)}',
              style: TextStyle(
                fontSize: index == 0 ? 26 : 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            );
          },
        ));
      }),
    );
  }

  String _format(num value) {
    final decimal = value.toDouble();
    return decimal == decimal.roundToDouble()
        ? decimal.toStringAsFixed(0)
        : decimal.toStringAsFixed(2);
  }
}
