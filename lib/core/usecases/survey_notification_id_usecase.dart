import 'package:survey_frontend/domain/local_services/notification_service.dart';
import 'package:survey_frontend/data/models/short_survey.dart';

abstract class SurveyNotificationIdUsecase {
  EncodedID getNotificationId(SurveyShortInfo survey, int index);
}

class SurveyNotificationIdUsecaseImpl implements SurveyNotificationIdUsecase {
  @override
  EncodedID getNotificationId(SurveyShortInfo survey, int index) {
    return EncodedID('notif${survey.timeSlotId}$index'.hashCode);
  }
}
