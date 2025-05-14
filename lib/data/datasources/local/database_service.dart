import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:survey_frontend/data/models/location_model.dart';
import 'package:survey_frontend/data/models/location_with_pending_survey_participation.dart';
import 'package:survey_frontend/data/models/sensor_data_model.dart';
import 'package:survey_frontend/data/models/short_survey.dart';
import 'package:survey_frontend/data/models/survey_calendar_event.dart';
import 'package:survey_frontend/data/models/upadte_location_participation.dart';
import 'package:survey_frontend/domain/models/localization_data.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';
import 'package:survey_frontend/domain/models/survey_with_time_slots.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  final GetStorage _storage = Get.find();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'survey_database.db');
    return await openDatabase(path,
        version: 5, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE timeSlots (
        id TEXT PRIMARY KEY,
        surveyId TEXT,
        start DATETIME,
        finish DATETIME,
        rowVersion INTEGER,
        FOREIGN KEY (surveyId) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE surveys (
        id TEXT PRIMARY KEY,
        name TEXT,
        rowVersion INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE sections (
        id TEXT PRIMARY KEY,
        surveyId TEXT,
        "order" INTEGER,
        name TEXT,
        visibility TEXT,
        groupId TEXT,
        rowVersion INTEGER,
        displayOnOneScreen BIT,
        FOREIGN KEY (surveyId) REFERENCES surveys (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id TEXT PRIMARY KEY,
        sectionId TEXT,
        "order" INTEGER,
        content TEXT,
        questionType TEXT,
        required INTEGER,
        rowVersion INTEGER,
        FOREIGN KEY (sectionId) REFERENCES sections (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE options (
        id TEXT PRIMARY KEY,
        questionId TEXT,
        "order" INTEGER,
        label TEXT,
        showSection INTEGER,
        rowVersion INTEGER,
        imagePath TEXT,
        FOREIGN KEY (questionId) REFERENCES questions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE number_ranges (
        id TEXT PRIMARY KEY,
        questionId TEXT,
        "from" INTEGER,
        "to" INTEGER,
        fromLabel TEXT,
        toLabel TEXT,
        rowVersion INTEGER
      )
    ''');

    await _onUpgrade(db, 0, version);
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE sensor_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        "dateTime" DATETIME,
        temperature REAL,
        humidity REAL,
        sentToServer BIT
      )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE locations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      surveyParticipationId TEXT,
      relatedToSurvey BIT,
      "dateTime" DATETIME,  
      latitude REAL,
      longitude REAL,
      sentToServer BIT)
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
      ALTER TABLE timeSlots ADD COLUMN submited BIT;
      ''');
      await db.execute('''
      ALTER TABLE timeSlots ADD COLUMN surveyName TEXT;
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('''
      ALTER TABLE locations ADD COLUMN accuracyMeters REAL;
      ''');
    }
  }

  Future<void> upsertSurveys(
      List<SurveyWithTimeSlots> surveysWithTimeSlots) async {
    final db = await database;
    int maxRowVersion = 0;
    await db.transaction((txn) async {
      for (var surveyWithTimeSlots in surveysWithTimeSlots) {
        await txn.insert(
          'surveys',
          {
            'id': surveyWithTimeSlots.survey.id,
            'name': surveyWithTimeSlots.survey.name,
            'rowVersion': surveyWithTimeSlots.survey.rowVersion,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        maxRowVersion =
            max(maxRowVersion, surveyWithTimeSlots.survey.rowVersion);

        for (var timeSlot in surveyWithTimeSlots.surveySendingPolicyTimes) {
          await txn.insert(
              'timeSlots',
              {
                'id': timeSlot.id,
                'surveyId': surveyWithTimeSlots.survey.id,
                'start': timeSlot.start.toIso8601String(),
                'finish': timeSlot.finish.toIso8601String(),
                'rowVersion': timeSlot.rowVersion,
                'surveyName': surveyWithTimeSlots.survey.name
              },
              conflictAlgorithm: ConflictAlgorithm.replace);

          maxRowVersion = max(maxRowVersion, timeSlot.rowVersion ?? 0);
        }

        for (var section in surveyWithTimeSlots.survey.sections) {
          await txn.insert(
            'sections',
            {
              'id': section.id,
              'surveyId': surveyWithTimeSlots.survey.id,
              'order': section.order,
              'name': section.name,
              'visibility': section.visibility,
              'groupId': section.groupId,
              'rowVersion': section.rowVersion,
              'displayOnOneScreen': section.displayOnOneScreen
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          maxRowVersion = max(maxRowVersion, section.rowVersion);

          for (var question in section.questions) {
            await txn.insert(
              'questions',
              {
                'id': question.id,
                'sectionId': section.id,
                'order': question.order,
                'content': question.content,
                'questionType': question.questionType,
                'required': question.required ? 1 : 0,
                'rowVersion': question.rowVersion,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            maxRowVersion = max(maxRowVersion, question.rowVersion);

            if (question.options != null) {
              for (var option in question.options!) {
                await txn.insert(
                  'options',
                  {
                    'id': option.id,
                    'questionId': question.id,
                    'order': option.order,
                    'label': option.label,
                    'showSection': option.showSection,
                    'rowVersion': option.rowVersion,
                    'imagePath': option.imagePath
                  },
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
                maxRowVersion = max(maxRowVersion, option.rowVersion);
              }
            }

            if (question.numberRange != null) {
              await txn.insert(
                'number_ranges',
                {
                  'id': question.numberRange!.id,
                  'from': question.numberRange!.from,
                  'to': question.numberRange!.to,
                  'questionId': question.id,
                  'fromLabel': question.numberRange!.fromLabel,
                  'toLabel': question.numberRange!.toLabel,
                  'rowVersion': question.numberRange!.rowVersion,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
              maxRowVersion =
                  max(maxRowVersion, question.numberRange!.rowVersion);
            }
          }
        }
      }
    });
    _updateMaxRowVersion(maxRowVersion);
  }

  bool _updateMaxRowVersion(int newRawVersion) {
    final currentMax = _storage.read<int>('surveysRowVersion');
    var changed = false;

    if (currentMax == null || currentMax < newRawVersion) {
      changed = true;
      _storage.write('surveysRowVersion', newRawVersion);
    }
    return changed;
  }

  Future<List<SurveyShortInfo>> getSurveysCompletableNow() async {
    final db = await database;
    final String currentDate = DateTime.now().toUtc().toIso8601String();
    final List<Map<String, dynamic>> surveyMaps = await db.rawQuery('''
        SELECT 
        surveys.id,
        surveys.name,
        timeSlots.start,
        timeSlots.finish,
        timeSlots.id as timeSlotId
        FROM surveys
        JOIN timeSlots ON timeSlots.surveyId = surveys.id
        WHERE timeSlots.start < ? AND timeSlots.finish > ?
        ''', [currentDate, currentDate]);

    return surveyMaps.map((e) {
      return SurveyShortInfo(
          name: e['name'],
          id: e['id'],
          finishTime: DateTime.parse(e['finish']),
          startTime: DateTime.parse(e['start']),
          timeSlotId: e['timeSlotId']);
    }).toList();
  }

  Future<List<SurveyShortInfo>> getFutureAndOngoingSurveys() async {
    final db = await database;
    final String currentDate = DateTime.now().toUtc().toIso8601String();
    final List<Map<String, dynamic>> surveyMaps = await db.rawQuery('''
        SELECT 
        surveys.id,
        surveys.name,
        timeSlots.start,
        timeSlots.finish,
        timeSlots.id as timeSlotId
        FROM surveys
        JOIN timeSlots ON timeSlots.surveyId = surveys.id
        WHERE timeSlots.finish > ? AND (timeSlots.submited = 0 OR timeSlots.submited IS NULL)
        ''', [currentDate]);

    return surveyMaps.map((e) {
      return SurveyShortInfo(
          name: e['name'],
          id: e['id'],
          finishTime: DateTime.parse(e['finish']),
          startTime: DateTime.parse(e['start']),
          timeSlotId: e['timeSlotId']);
    }).toList();
  }

  Future markAsSubmited(String id) async {
    final db = await database;
    final String currentDate = DateTime.now().toUtc().toIso8601String();
    await db.update('timeSlots', {'submited': 1, 'surveyId': null},
        where: 'surveyId = ? and start <= ? and finish >= ?',
        whereArgs: [id, currentDate, currentDate]);
  }

  Future<void> clearAllSurveysRelatedTables() async {
    final db = await database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.delete('timeSlots', where: 'finish >= ? AND (submited = 0 OR submited IS NULL)', whereArgs: [now]);
    await db.delete('surveys');
    await db.delete('sections');
    await db.delete('questions');
    await db.delete('options');
    await db.delete('number_ranges');
  }

  Future<void> clearAllTables() async {
    await clearAllSurveysRelatedTables();
    final db = await database;
    await db.delete('sensor_data');
    await db.delete('timeSlots');
    await db.delete('locations');
  }

  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<SurveyDto> getSurveyById(String id) async {
    final db = await database;
    final Map<String, dynamic> surveyMap = Map.from((await db.rawQuery('''
      SELECT id, name, rowVersion
      FROM surveys
      WHERE id = ?
      ''', [id])).first);
    surveyMap['sections'] = await _getSections(id, db);

    return SurveyDto.fromJson(surveyMap);
  }

  Future<List<Map<String, dynamic>>> _getSections(
      String surveyId, Database db) async {
    final List<Map<String, dynamic>> sections = (await db.rawQuery('''
      SELECT id, "order", name, visibility, groupId, rowVersion, displayOnOneScreen
      FROM sections 
      WHERE surveyId = ?
      ''', [surveyId])).map((e) {
      final Map<String, dynamic> res = Map.from(e);
      return res;
    }).toList();

    final List<String> sectionsIds =
        sections.map((e) => e['id'] as String).toList();
    final questionsMap = await _getQuestionsToSectionMappings(sectionsIds, db);

    final questionsIds = questionsMap.values
        .expand((e) => e)
        .map((e) => e['id'] as String)
        .toList();
    final optionsMap = await _getOptionsToQuestionsMappings(questionsIds, db);
    final numberRangesMap =
        await _getNumberRangesToQuestionsMappings(questionsIds, db);

    for (final section in sections) {
      section['displayOnOneScreen'] = section['displayOnOneScreen'] == 1;
      section['questions'] = questionsMap[section['id']];

      for (final question in section['questions']) {
        question['required'] = question['required'] == 1;
        final questionId = question['id'];
        if (optionsMap.containsKey(questionId)) {
          question['options'] = optionsMap[questionId]!.toList();
        }

        if (numberRangesMap.containsKey(questionId)) {
          question['numberRange'] =
              numberRangesMap[questionId] as Map<String, dynamic>;
        }
      }
    }

    return sections;
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      _getQuestionsToSectionMappings(
          List<String> sectionsIds, Database db) async {
    final List<Map<String, dynamic>> questions = (await db.rawQuery('''
      SELECT id, "order", content, questionType, required, rowVersion, sectionId
      FROM questions
      WHERE sectionId IN (${List.filled(sectionsIds.length, '?').join(', ')})
      ''', sectionsIds)).map((e) {
      final Map<String, dynamic> res = Map.from(e);
      return res;
    }).toList();

    return groupBy(questions, (map) => map['sectionId'] as String);
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      _getOptionsToQuestionsMappings(
          List<String> questionsIds, Database db) async {
    final List<Map<String, dynamic>> options = (await db.rawQuery('''
      SELECT id, "order", label, showSection, rowVersion, imagePath, questionId
      FROM options
      WHERE questionId IN (${List.filled(questionsIds.length, '?').join(', ')})
      ''', questionsIds));

    return groupBy(options, (map) => map['questionId'] as String);
  }

  Future<Map<String, Map<String, dynamic>>> _getNumberRangesToQuestionsMappings(
      List<String> questionsIds, Database db) async {
    final List<Map<String, dynamic>> numberRanges = (await db.rawQuery('''
      SELECT id, "from", "to", fromLabel, toLabel, rowVersion, questionId
      FROM number_ranges
      WHERE questionId IN (${List.filled(questionsIds.length, '?').join(', ')})
      ''', questionsIds));

    return {for (var e in numberRanges) e['questionId']: e};
  }

  Future<List<SurveyCalendarEvent>> getCalendarEvents() async {
    final db = await database;

    const String command = '''
    SELECT timeSlots.id as timeSlotId, 
    timeSlots.start as "from", 
    timeSlots.finish as "to", 
    timeSlots.surveyName as "name",
    submited
    FROM timeSlots
    ''';
    final result = await db.rawQuery(command);

    return result
        .map((e) => SurveyCalendarEvent(
            surveyName: e['name'] == null ? '' : e['name'] as String, //TODO: on one of the phones, there was a bug here because the name was null. This should fix the problem, but I have no idea in what way did the survey name be null
            timeSlotId: e['timeSlotId'] as String,
            from: DateTime.parse(e['from'] as String),
            to: DateTime.parse(e['to'] as String),
            submited: e['submited'] == 1))
        .toList();
  }

  Future<void> addSensorData(SensorDataModel sensorData) async {
    final db = await database;
    await db.insert('sensor_data', {
      'dateTime': sensorData.dateTime.toIso8601String(),
      'temperature': sensorData.temperature,
      'humidity': sensorData.humidity,
      'sentToServer': sensorData.sentToServer ? 1 : 0
    });
  }

  Future<List<SensorDataModel>> getAllSensorDataFilterByDate(
      DateTime from, DateTime to) async {
    final db = await database;
    final results = await db.rawQuery('''
    SELECT "dateTime", temperature, humidity, sentToServer
    FROM sensor_data 
    WHERE "dateTime" >= ? AND "dateTime" <= ?
    ''', [from.toIso8601String(), to.toIso8601String()]);

    return _mapToSensorDataModel(results);
  }

  List<SensorDataModel> _mapToSensorDataModel(
      List<Map<String, dynamic>> items) {
    return items
        .map((e) => SensorDataModel(
            dateTime: DateTime.parse(e['dateTime'] as String),
            temperature: e['temperature'] as double,
            humidity: e['humidity'] as double,
            sentToServer: e['sentToServer'] == 1))
        .toList();
  }

  Future<List<SensorDataModel>> getAlSensorDataNotSentToServer() async {
    final db = await database;
    final results = await db.rawQuery('''
    SELECT "dateTime", temperature, humidity, sentToServer
    FROM sensor_data 
    WHERE sentToServer = 0
    ''');

    return _mapToSensorDataModel(results);
  }

  Future<void> markAllSensorDataSentToServer() async {
    final db = await database;

    await db.execute('''
    UPDATE sensor_data SET sentToServer = 1
    ''');
  }

  Future<void> addLocation(LocationModel model) async {
    final db = await database;
    await db.insert('locations', {
      'surveyParticipationId': model.surveyParticipationId,
      'relatedToSurvey': model.relatedToSurvey ? 1 : 0,
      'dateTime': model.dateTime.toIso8601String(),
      'latitude': model.latitude,
      'longitude': model.longitude,
      'sentToServer': model.sentToServer ? 1 : 0,
      'accuracyMeters': model.accuracyMeters
    });
  }

  Future<List<LocalizationData>> getAllLocationsToSend(DateTime toDate) async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT surveyParticipationId, "dateTime",
      latitude, longitude, accuracyMeters
      FROM locations
      WHERE sentToServer = 0 AND (relatedToSurvey = 0 OR surveyParticipationId IS NOT NULL)
      AND "dateTime" <= ?;
      ''', [toDate.toIso8601String()]);

    return results
        .map((e) => LocalizationData(
            surveyParticipationId: e['surveyParticipationId'] as String?,
            dateTime: e['dateTime'] as String,
            latitude: e['latitude'] as double,
            longitude: e['longitude'] as double,
            accuracyMeters: e['accuracyMeters'] as double?))
        .toList();
  }

  Future<void> markAllSendableLocationsSentToServer(DateTime toDate) async {
    final db = await database;
    await db.execute('''
    UPDATE locations set sentToServer = 1 WHERE sentToServer = 0 AND (relatedToSurvey = 0 OR surveyParticipationId IS NOT NULL)
    AND "dateTime" <= ?;
    ''', [toDate.toIso8601String()]);
  }

  Future<List<LocationModel>> getAllLocationsBetween(
      DateTime from, DateTime to) async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT surveyParticipationId, "dateTime",
      relatedToSurvey, sentToServer,
      latitude, longitude
      FROM locations
      WHERE "dateTime" >= ? AND "dateTime" <= ?
      ''', [from.toIso8601String(), to.toIso8601String()]);

    return results
        .map((e) => LocationModel(
            dateTime: DateTime.parse(e['dateTime'] as String),
            longitude: e['longitude'] as double,
            latitude: e['latitude'] as double,
            sentToServer: e['sentToServer'] == 1,
            relatedToSurvey: e['relatedToSurvey'] == 1,
            surveyParticipationId: e['surveyParticipationId'] as String?,
            accuracyMeters: e['accuracyMeters'] as double?))
        .toList();
  }

  Future<List<LocationWithPendingSurveyParticipation>>
      getLocationsWithPendingSurveyParticipations() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT id, "dateTime"
      FROM locations
      WHERE relatedToSurvey = 1 AND surveyParticipationId IS NULL
      ''');

    return results
        .map((e) => LocationWithPendingSurveyParticipation(
            id: e['id'] as int,
            dateTime: DateTime.parse(e['dateTime'] as String)))
        .toList();
  }

  Future<void> updateParticipations(
      List<UpadteLocationParticipation> updates) async {
    final db = await database;
    for (final update in updates) {
      await db.update(
          'locations', {'surveyParticipationId': update.surveyParticipationId},
          where: 'id = ?', whereArgs: [update.id]);
    }
  }

  Future<Duration?> getTimeToNextSurvey() async {
    final db = await database;
    final now = DateTime.now().toUtc();
    final results = await db
        .rawQuery('SELECT "start" FROM timeSlots WHERE (submited = 0 OR submited IS NULL) and "finish" > ? ORDER BY "start" ASC LIMIT 1;',
        [now.toIso8601String()]);
    if (results.isEmpty) return null;
    return DateTime.parse(results.first['start'] as String).difference(now);
  }
}
