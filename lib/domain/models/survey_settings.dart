class SurveySettings {
  static const String showSendingPolicyCalendarStorageKey =
      'showSendingPolicyCalendar';

  final bool showSendingPolicyCalendar;

  const SurveySettings({required this.showSendingPolicyCalendar});

  factory SurveySettings.fromJson(Map<String, dynamic> json) {
    return SurveySettings(
      showSendingPolicyCalendar:
          json['showSendingPolicyCalendar'] as bool? ?? true,
    );
  }
}
