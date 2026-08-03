import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';

class SensorScanningResultCircle extends StatelessWidget {
  final RxList<SensorDataValue> sensorValues;

  const SensorScanningResultCircle({super.key, required this.sensorValues});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Theme.of(context).cardColor),
      child: Obx(() {
        if (sensorValues.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                getAppLocalizations().sensorReadingCannotBeStored,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final values = sensorValues.toList();
        return Center(
            child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: values.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final value = values[index];
            return Text(
              '${value.parameterCode}: ${_format(value.value)}',
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

  String _format(String value) {
    final decimal = num.tryParse(value)?.toDouble();
    if (decimal == null) return value;
    return decimal == decimal.roundToDouble()
        ? decimal.toStringAsFixed(0)
        : decimal.toStringAsFixed(2);
  }
}
