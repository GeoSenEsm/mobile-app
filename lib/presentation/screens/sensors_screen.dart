import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/controllers/sensors_controller.dart';

class SensorsScreen extends GetView<SensorsController> {
  const SensorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.editSensor)),
      body: Obx(() {
        if (controller.assignedSensors.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                AppLocalizations.of(context)!.noSensorsAssigned,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(10.0),
          itemCount: controller.assignedSensors.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final sensor = controller.assignedSensors[index];
            final subtitleLines = [
              if (sensor.mac != null)
                '${AppLocalizations.of(context)!.sensorMac}: ${sensor.mac}',
              if (sensor.parameterNames.isNotEmpty)
                AppLocalizations.of(context)!
                    .sensorReadsParameters(sensor.parameterNames.join(', ')),
            ];
            return ListTile(
              leading: const Icon(Icons.sensors),
              title: Text(sensor.name),
              subtitle: subtitleLines.isEmpty
                  ? null
                  : Text(subtitleLines.join('\n')),
            );
          },
        );
      }),
    );
  }
}
