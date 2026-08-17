import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/models/need_insert_respondent_data_result.dart';
import 'package:survey_frontend/core/usecases/need_insert_respondent_data_usecase.dart';
import 'package:survey_frontend/core/utils/study_time_zone.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/domain/usecases/token_validity_checker.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/functions/handle_need_insert_respondent_data.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class LoadingController extends ControllerBase {
  final GetStorage _storage;
  final TokenValidityChecker _tokenValidityChecker;
  final NeedInsertRespondentDataUseCase _needInsertRespondentDataUseCase;

  Rx<bool> retryButtonVisible = false.obs;

  LoadingController(this._storage, this._tokenValidityChecker,
      this._needInsertRespondentDataUseCase);

  void goToNextPage() async {
    retryButtonVisible.value = false;
    String? savedToken = _storage.read<String>("apiToken");
    if (savedToken == null) {
      Get.offAllNamed(Routes.login);
      return;
    }

    if (!_tokenValidityChecker.isValid(savedToken)) {
      Get.offAllNamed(Routes.reinsertCredentials);
      return;
    }

    // The login screen is the only other place the device timezone gets captured; a respondent
    // who already holds a valid token skips it entirely on every app start from here on, so
    // without this they'd never get one recorded and local wall-clock interpretation (see
    // DatabaseHelper.upsertSurveys) would silently default to UTC.
    await _syncDeviceTimeZone();

    var respondentData = _storage.read<dynamic>("respondentData");

    if (respondentData != null) {
      _needInsertRespondentDataUseCase.update(respondentData['id']);
      goToNamedPrivacySave(Routes.home);
      return;
    }

    if (!await hasInternetConnectionNoDialog()) {
      await Get.defaultDialog(
        barrierDismissible: false,
        title: getAppLocalizations().noInternetConnection,
        middleText: getAppLocalizations().betterExperienceTurnOnInternet,
        textConfirm: getAppLocalizations().ok,
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
        },
      );
    }

    final needResult =
        await _needInsertRespondentDataUseCase.needInsertRespondentData();
    handle(needResult);

    if (needResult == NeedInsertRespondentDataResult.error) {
      retryButtonVisible.value = true;
    }
  }

  /// Mirrors what a real login does with the detected timezone (see
  /// LoginController._attachDeviceTimeZone): cache it locally, and if it differs from whatever
  /// was cached before — including "nothing was ever cached" — clear locally stored survey data
  /// so the next sync re-fetches slots interpreted under the correct zone instead of the stale
  /// or default one.
  Future<void> _syncDeviceTimeZone() async {
    final previousTimeZone = _storage.read<String>(StudyTimeZone.storageKey);
    final timeZone = await StudyTimeZone.detectAndCache(_storage);
    if (timeZone == null) {
      return;
    }
    if (previousTimeZone == null || previousTimeZone != timeZone) {
      _storage.remove('surveysRowVersion');
      await DatabaseHelper().clearAllSurveysRelatedTables();
    }
  }
}
