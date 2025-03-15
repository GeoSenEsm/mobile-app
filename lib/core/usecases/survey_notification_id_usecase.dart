import 'package:survey_frontend/data/models/short_survey.dart';
import 'package:survey_frontend/domain/local_services/notification_service.dart';

abstract class SurveyNotificationIdUsecase {
  EncodedID getStartNotificationId(SurveyShortInfo surveyshort);
  EncodedID getFinishNotificationId(SurveyShortInfo surveyshort);
}

class SurveyNotificationIdUsecaseImpl implements SurveyNotificationIdUsecase {
  @override
  EncodedID getStartNotificationId(SurveyShortInfo surveyshort) {
    //not completly unique, but probabvility that that it is unique is almost 1
    return EncodedID('start${surveyshort.timeSlotId}'.hashCode);
  }

  @override
  EncodedID getFinishNotificationId(SurveyShortInfo surveyshort) {
    //not completly unique, but probabvility that that it is unique is almost 1
    return EncodedID('finish${surveyshort.timeSlotId}'.hashCode);
  }
}