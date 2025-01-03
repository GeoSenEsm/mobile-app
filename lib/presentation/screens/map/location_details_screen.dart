import 'package:flutter/material.dart';
import 'package:survey_frontend/data/models/location_model.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/functions/formatters.dart';

class LocationDetailsScreen extends StatelessWidget {
  final LocationModel model;

  const LocationDetailsScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                    label: Text(getAppLocalizations().latidude)),
                initialValue: model.latitude.toString(),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                    label: Text(getAppLocalizations().longitude)),
                initialValue: model.longitude.toString(),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                readOnly: true,
                decoration:
                    InputDecoration(label: Text(getAppLocalizations().date)),
                initialValue: dateOnlyShortFormat(model.dateTime.toLocal()),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                readOnly: true,
                decoration:
                    InputDecoration(label: Text(getAppLocalizations().time)),
                initialValue: timeOnlyShortFormat(model.dateTime.toLocal()),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    model.sentToServer ? Icons.info_rounded : Icons.warning,
                    color: model.sentToServer ? Colors.blue : Colors.red,
                    size: 40,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: Text(
                      model.sentToServer
                          ? getAppLocalizations()
                              .theLocationDataHasBeenSubmitedToServer
                          : getAppLocalizations()
                              .theLocationDataHasNotBeenSubmitedToServer,
                      style: const TextStyle(fontSize: 25),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(color: Colors.black),
              const SizedBox(
                height: 10,
              ),
              _buildRelatedWithSurveyWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedWithSurveyWidget() {
    if (!model.relatedToSurvey) {
      return const SizedBox(
        height: 0,
      );
    }

    return Row(
      children: [
        const Icon(
          Icons.info_rounded,
          color: Colors.blue,
          size: 40,
        ),
        const SizedBox(
          width: 20,
        ),
        Flexible(
          child: Text(
            getAppLocalizations().surveyHasBeenComplitedInThisLocation,
            style: const TextStyle(fontSize: 25),
          ),
        )
      ],
    );
  }
}
