import 'package:intl/intl.dart';
import 'package:survey_frontend/presentation/static/static_variables.dart';

String dateShortFormat(DateTime dateTime) {
  String culture = StaticVariables.lang == 'pl' ? 'pl_PL' : 'en_EN';
  return DateFormat.yMd(culture).add_Hm().format(dateTime);
}