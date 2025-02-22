import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/usecases/survey_images_usecase.dart';
import 'package:survey_frontend/domain/models/create_selected_option_dto.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';

class ImageTypeQuestion extends StatefulWidget {
  final Question question;
  final CreateSelectedOptionDto selectedOption;
  final SurveyImagesUseCase surveyImagesUseCase;

  const ImageTypeQuestion(
      {super.key,
      required this.question,
      required this.selectedOption,
      required this.surveyImagesUseCase});

  @override
  State<StatefulWidget> createState() {
    return _ImageTypeQuestionState();
  }
}

class _ImageTypeQuestionState extends State<ImageTypeQuestion> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.from(widget.question.options!.map((option) =>
          RadioListTile(
              title: _ImageWidget(
                  option: option,
                  surveyImagesUseCase: widget.surveyImagesUseCase),
              value: option.id,
              groupValue: widget.selectedOption.optionId,
              onChanged: (v) {
                setState(() {
                  widget.selectedOption.optionId = v;
                });
              }))),
    );
  }
}

class _ImageWidget extends StatefulWidget {
  final Option option;
  final SurveyImagesUseCase surveyImagesUseCase;

  const _ImageWidget(
      {required this.option, required this.surveyImagesUseCase});

  @override
  State<StatefulWidget> createState() {
    return _ImageWidgetState();
  }
}

class _ImageWidgetState extends State<_ImageWidget> {
  Widget? _actualImage;

  @override
  void initState() {
    loadActualImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _actualImage == null ? _buildLoadingIndicator(context) : _actualImage!;
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return SpinKitCircle(size: 150, color: Theme.of(context).primaryColor);
  }

  Widget buildErrorWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.error, size: 100, color: Colors.red),
        Text(
          getAppLocalizations().loadingImageFailed,
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  void loadActualImage() async {
    final file = await widget.surveyImagesUseCase.getImageFile(widget.option);
    if (file != null) {
      setState(() {
        _actualImage = Image.file(file,
            height: 150, width: double.infinity, fit: BoxFit.contain);
      });
      return;
    }

    final storage = GetStorage();
    setState(() {
      _actualImage = Image.network(
      storage.read<String>('apiUrl')! + widget.option.imagePath!,
      errorBuilder: (ctx, obj, st) => buildErrorWidget(),
    );
    });
  }
}
