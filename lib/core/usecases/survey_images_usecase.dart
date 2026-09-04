import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/domain/models/question_type.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';
import 'package:survey_frontend/domain/models/survey_with_time_slots.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

abstract class SurveyImagesUseCase {
  Future<void> saveImages(List<SurveyWithTimeSlots> surveys);
  Future<File?> getImageFile(Option option);
  Future<void> clearImages();
}

class SurveyImagesUseCaseImpl implements SurveyImagesUseCase {
  final GetStorage _storage;

  SurveyImagesUseCaseImpl(this._storage);

  @override
  Future<void> saveImages(List<SurveyWithTimeSlots> surveys) async {
    final docsDir = await getApplicationSupportDirectory();
    final imagesDirPath = p.join(docsDir.path, 'survey_images');
    final imagesDir = Directory(imagesDirPath);
    await _clearDir(imagesDir);

    for (final survey in surveys) {
      await _saveImagesForSurvey(survey, imagesDir);
    }
  }

  @override
  Future<void> clearImages() async {
    final docsDir = await getApplicationSupportDirectory();
    final imagesDirPath = p.join(docsDir.path, 'survey_images');
    final imagesDir = Directory(imagesDirPath);
    await _clearDir(imagesDir);
  }

  Future<void> _clearDir(Directory dir) async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create();
    }
  }

  Future<void> _saveImagesForSurvey(
      SurveyWithTimeSlots survey, Directory imagesDir) async {
    for (final section in survey.survey.sections) {
      await _saveImagesForSection(section, imagesDir);
    }
  }

  Future<void> _saveImagesForSection(
      Section section, Directory imagesDir) async {
    for (final question in section.questions) {
      await _saveImagesForQuestion(question, imagesDir);
    }
  }

  Future<void> _saveImagesForQuestion(
      Question question, Directory imagesDir) async {
    if (question.questionType != QuestionType.imageChoice) {
      return;
    }

    for (final option in question.options ?? []) {
      await _saveImageForOption(option, imagesDir);
    }
  }

  Future<void> _saveImageForOption(Option option, Directory imagesDir) async {
    var imagePath = p.join(imagesDir.path, option.imagePath!.substring(1));
    final apiUrl = _storage.read<String>('apiUrl')!;
    final response = await http.get(Uri.parse(apiUrl + option.imagePath!));

    if (response.statusCode != 200) {
      return;
    }

    final dirName = p.dirname(imagePath);
    final dir = Directory(dirName);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File(imagePath);
    await file.writeAsBytes(response.bodyBytes);
  }

  @override
  Future<File?> getImageFile(Option option) async {
    if (option.imagePath == null) {
      return null;
    }

    final docsDir = await getApplicationSupportDirectory();
    final imagePath =
        p.join(docsDir.path, 'survey_images', option.imagePath!.substring(1));
    final file = File(imagePath);

    if (!await file.exists()) {
      return null;
    }

    return file;
  }
}
