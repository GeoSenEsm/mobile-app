import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:survey_frontend/presentation/controllers/sensors_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SensorsScreen extends GetView<SensorsController>
{
  const SensorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.chooseATemperatureSensorYouReceived, 
              style: const TextStyle(fontSize: 24), textAlign: TextAlign.center,),
              const SizedBox(height: 20,),
               DropdownButtonFormField<String>(
                onChanged:(value) {
                  controller.selectedSensor.value = value!;
                },
                value: controller.selectedSensor.value,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.usedSensor),
                isExpanded: true,
                items: controller.possibleOptions
                    .map((val) => DropdownMenuItem(
                          value: val,
                          child: Text(controller.optionsDisplays[val]!),
                        ))
                    .toList(),
              ),
            ],
          ),
        )
    ),
    bottomNavigationBar: SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            controller.saveSelectedSensor();
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ),
    ),);
  }
}