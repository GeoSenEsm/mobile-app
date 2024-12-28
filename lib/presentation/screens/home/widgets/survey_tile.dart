import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:survey_frontend/data/models/short_survey.dart';
import 'package:survey_frontend/presentation/functions/formatters.dart';


class SurveyTile extends StatelessWidget {
  final SurveyShortInfo surveyShortInfo;
  final void Function() onPressed;

  const SurveyTile(
      {super.key, required this.surveyShortInfo, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).hintColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          trailing: SvgPicture.asset(
            'assets/bell.svg',
            height: 32, // Adjust the height as needed
            colorFilter:
                ColorFilter.mode(
                Theme.of(context).highlightColor, BlendMode.srcIn),
          ),
          title: Text(
            surveyShortInfo.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            overflow: TextOverflow.ellipsis,
            '${timeOnlyShortFormat(surveyShortInfo.startTime)} - ${timeOnlyShortFormat(surveyShortInfo.finishTime)}',
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: onPressed,
        ),
      ),
    );
  }
}
