import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/core/models/date_filters.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/widgets/date_picker.dart';
import 'package:survey_frontend/presentation/widgets/time_picker.dart';

class DateFiltersScreen extends StatelessWidget {
  final DateFilters originalFilters;
  late DateFilters tempFilters;

  DateFiltersScreen({super.key, required this.originalFilters}) {
    tempFilters =
        DateFilters(from: originalFilters.from, to: originalFilters.to);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DatePicker(
              value: tempFilters.from,
              onValueChanged: (v) {
                if (v != null) {
                  tempFilters.from = DateTime(
                      v.year,
                      v.month,
                      v.day,
                      tempFilters.from?.hour ?? 0,
                      tempFilters.from?.minute ?? 0);
                }
              },
              label: getAppLocalizations().dateFrom,
            ),
            const SizedBox(
              height: 10,
            ),
            TimePicker(
              label: getAppLocalizations().timeFrom,
              value: tempFilters.from == null
                  ? null
                  : TimeOfDay(
                      hour: tempFilters.from!.hour,
                      minute: tempFilters.from!.minute),
              onChange: (v) {
                final date = tempFilters.from ?? DateTime.now();
                tempFilters.from = DateTime(date.year, date.month, date.day,
                    v?.hour ?? 0, v?.minute ?? 0);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            DatePicker(
              value: tempFilters.to,
              onValueChanged: (v) {
                if (v != null) {
                  tempFilters.to = DateTime(v.year, v.month, v.day,
                      tempFilters.to?.hour ?? 0, tempFilters.to?.minute ?? 0);
                }
              },
              label: getAppLocalizations().dateTo,
            ),
            const SizedBox(
              height: 10,
            ),
            TimePicker(
              label: getAppLocalizations().timeTo,
              value: tempFilters.to == null
                  ? null
                  : TimeOfDay(
                      hour: tempFilters.to!.hour,
                      minute: tempFilters.to!.minute),
              onChange: (v) {
                final date = tempFilters.to ?? DateTime.now();
                tempFilters.to = DateTime(date.year, date.month, date.day,
                    v?.hour ?? 0, v?.minute ?? 0);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
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
                  onPressed: () {
                    originalFilters.from = null;
                    originalFilters.to = null;
                    Get.back();
                  },
                  child: Text(getAppLocalizations().clearFilters),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    originalFilters.from = tempFilters.from;
                    originalFilters.to = tempFilters.to;
                    Get.back();
                  },
                  child: Text(getAppLocalizations().apply),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
