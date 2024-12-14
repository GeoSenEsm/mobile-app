import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/models/need_insert_respondent_data_result.dart';
import 'package:survey_frontend/core/usecases/need_insert_respondent_data_usecase.dart';
import 'package:survey_frontend/domain/usecases/token_validity_checker.dart';
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

    if (!_tokenValidityChecker.isValid(savedToken)){
      Get.offAllNamed(Routes.reinsertCredentials);
      return;
    }

    var respondentData = _storage.read<dynamic>("respondentData");    

    if (respondentData != null) {
      goToNamedPrivacySave(Routes.home);
      return;
    }

    if (await connectivity.checkConnectivity() == ConnectivityResult.none) {
      retryButtonVisible.value = true;
      return;
    }

    final needResult =
        await _needInsertRespondentDataUseCase.needInsertRespondentData();
    handle(needResult);

    if (needResult == NeedInsertRespondentDataResult.error) {
      retryButtonVisible.value = true;
    }
  }
}
