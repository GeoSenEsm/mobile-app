import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/data/models/survey_calendar_event.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/app_styles.dart';
import 'package:survey_frontend/presentation/controllers/calendar_controller.dart';
import 'package:survey_frontend/presentation/screens/calendar/widgets/event_tile.dart';

class CalendarScreen extends GetView<CalendarController> {
  const CalendarScreen({super.key});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getAppLocalizations().calendar,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
                textScaler: const TextScaler.linear(1),
              ),
              Obx(() => DropdownButton<CalendarView>(
                  value: controller.selectedView.value,
                  items: CalendarView.values
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              controller.getCalendarViewDisplay(e),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      controller.selectedView.value = v;
                    }
                  })),
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
            child: CalendarControllerProvider(
                controller: controller.eventController,
                child: Obx(() {
                  if (controller.selectedView.value == CalendarView.day) {
                    return _buildDayView(context);
                  }
                  return _buildWeekView(context);
                })),
          ),
        ),
      ],
    ));
  }

  Widget _buildDayView(BuildContext context) {
    return DayView(
      fullDayEventBuilder: (event, day) => Container(),
      eventTileBuilder: (date, events, rect, from, to) {
        return EventTile(
            calendarEvent: events.first.event as SurveyCalendarEvent);
      },
      onEventTap: _eventTap,
      showLiveTimeLineInAllDays: true,
      eventArranger: const SideEventArranger(),
      headerStyle: HeaderStyle(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor)),
    );
  }

  _eventTap(List<CalendarEventData<Object?>> events, DateTime date) {
    controller.onEventTap(events.first.event as SurveyCalendarEvent);
  }

  Widget _buildWeekView(BuildContext context) {
    return WeekView(
      fullDayEventBuilder: (event, day) => Container(),
      eventTileBuilder: (date, events, rect, from, to) {
        return EventTile(
            calendarEvent: events.first.event as SurveyCalendarEvent);
      },
      onEventTap: _eventTap,
      showLiveTimeLineInAllDays: true,
      eventArranger: const SideEventArranger(),
      headerStyle: HeaderStyle(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor)),
    );
  }
}
