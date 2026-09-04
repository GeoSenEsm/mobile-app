import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';

class AcceptPrivacyPolicyController extends ControllerBase{
  final GetStorage _storage;
  final RxBool accepted = false.obs;
  RxBool scrolled = false.obs;
  bool isBusy = false;
  late String nextPage;

  AcceptPrivacyPolicyController(this._storage);

  void next() async{
    if (!accepted.value || isBusy){
      return;
    }

    try{
      isBusy = true;
      await _storage.write('privacyPolicyAccepted', true);
      await Get.offAllNamed(nextPage);
    } finally{
      isBusy = false;
    } 
  }

  void readGetArguments(){
    nextPage = Get.arguments['nextPage'];
  }
}