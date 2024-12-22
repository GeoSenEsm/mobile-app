import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/sensor_data_history_controller.dart';
import 'package:survey_frontend/presentation/functions/formatters.dart';

class SensorDataHistoryScreen extends GetView<SensorDataHistoryController> {
  const SensorDataHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 60,
          ),
          _buildTopBar(),
          Expanded(
            child: Container(
              color: AppStyles.backgroundSecondary,
              child: Column(
                children: [_buildFilters(context), _buildDataGrid(context)],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppStyles.backgroundSecondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getAppLocalizations().sensorHistory,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
          ),
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
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Wrap(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(() {
              final style = TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.bold);

              if (controller.from.value == null &&
                  controller.to.value == null) {
                return Text(getAppLocalizations().thisWeek, style: style);
              }

              final fromString = controller.from.value == null
                  ? ''
                  : dateTimeShortFormat(controller.from.value!);
              final toString = controller.to.value == null
                  ? ''
                  : dateTimeShortFormat(controller.to.value!);
              return Text(
                '$fromString - $toString',
                style: style,
              );
            }),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
                onPressed: controller.openFilters,
                child: const Icon(Icons.filter_alt)),
          )
        ],
      ),
    );
  }

  Widget _buildDataGrid(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(() => DataTable(
                columns: [
                  DataColumn(label: Text(getAppLocalizations().date)),
                  DataColumn(label: Text(getAppLocalizations().temperature)),
                  DataColumn(label: Text(getAppLocalizations().humidity)),
                  DataColumn(label: Text(getAppLocalizations().sentToServer))
                ],
                rows: controller.entries
                    .map((e) => DataRow(cells: [
                          DataCell(Center(
                              child:
                                  Text(dateTimeShortFormat(e.dateTime.toLocal())))),
                          DataCell(Center(child: Text('${e.temperature} °C'))),
                          DataCell(Center(child: Text('${e.humidity}%'))),
                          DataCell(Center(
                              child: Icon(
                            e.sentToServer ? Icons.check : Icons.close,
                            color: e.sentToServer ? Colors.green : Colors.red,
                          ))),
                        ]))
                    .toList(),
              )),
        ),
      ),
    );
  }
}
