import 'package:json_annotation/json_annotation.dart';

part 'survey_dto.g.dart';

@JsonSerializable()
class SurveyDto {
  final String id;
  final String name;
  final int rowVersion;
  final List<Section> sections;
  final List<SurveyNotificationDto> notifications;

  SurveyDto({
    required this.id,
    required this.name,
    required this.rowVersion,
    required this.sections,
    this.notifications = const [],
  });

  factory SurveyDto.fromJson(Map<String, dynamic> json) {
    final survey = _$SurveyDtoFromJson(json);
    survey.sections.sort((a, b) => a.order.compareTo(b.order));
    final notifications = List<SurveyNotificationDto>.of(survey.notifications)
      ..sort((a, b) => a.order.compareTo(b.order));
    return SurveyDto(
      id: survey.id,
      name: survey.name,
      rowVersion: survey.rowVersion,
      sections: survey.sections,
      notifications: notifications,
    );
  }

  Map<String, dynamic> toJson() => _$SurveyDtoToJson(this);
}

@JsonSerializable()
class SurveyNotificationDto {
  final String? id;
  final int order;
  final String relativeTo;
  final int minutesBefore;

  SurveyNotificationDto({
    this.id,
    required this.order,
    required this.relativeTo,
    required this.minutesBefore,
  });

  factory SurveyNotificationDto.fromJson(Map<String, dynamic> json) =>
      _$SurveyNotificationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SurveyNotificationDtoToJson(this);
}

@JsonSerializable()
class Section {
  final String id;
  final int order;
  final String name;
  final String visibility;
  final String? groupId;
  final int rowVersion;
  final bool displayOnOneScreen;
  final List<Question> questions;

  Section({
    required this.id,
    required this.order,
    required this.name,
    required this.visibility,
    this.groupId,
    required this.rowVersion,
    required this.displayOnOneScreen,
    required this.questions,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    final section = _$SectionFromJson(json);
    section.questions.sort((a, b) => a.order.compareTo(b.order));
    return section;
  }

  Map<String, dynamic> toJson() => _$SectionToJson(this);
}

@JsonSerializable()
class Question {
  final String id;
  final int order;
  final String content;
  final String questionType;
  final bool required;
  final int rowVersion;
  final List<Option>? options;
  final NumberRange? numberRange;

  Question({
    required this.id,
    required this.order,
    required this.content,
    required this.questionType,
    required this.required,
    required this.rowVersion,
    this.options,
    this.numberRange,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final question = _$QuestionFromJson(json);
    question.options?.sort((a, b) => a.order.compareTo(b.order));
    return question;
  }

  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}

@JsonSerializable()
class Option {
  final String id;
  final int order;
  final String label;
  final int? showSection;
  final int rowVersion;
  final String? imagePath;

  Option({
    required this.id,
    required this.order,
    required this.label,
    this.showSection,
    required this.rowVersion,
    this.imagePath
  });

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);

  Map<String, dynamic> toJson() => _$OptionToJson(this);
}

@JsonSerializable()
class NumberRange {
  final String id;
  final int from;
  final int to;
  final String? fromLabel;
  final String? toLabel;
  final int rowVersion;

  NumberRange({
    required this.id,
    required this.from,
    required this.to,
    this.fromLabel,
    this.toLabel,
    required this.rowVersion,
  });

  factory NumberRange.fromJson(Map<String, dynamic> json) =>
      _$NumberRangeFromJson(json);

  Map<String, dynamic> toJson() => _$NumberRangeToJson(this);
}
