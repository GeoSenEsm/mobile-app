import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SensorsController extends ControllerBase
{
  final Rx<String> selectedSensor = Rx<String>(SensorKind.none);
  final GetStorage _storage;

  SensorsController(this._storage){
    _loadSelectedSensor();
  }

  final List<String> possibleOptions = [
    SensorKind.none,
    SensorKind.xiaomi,
    SensorKind.kestrelDrop2
  ];

  final Map<String, String> optionsDisplays = {
    SensorKind.none: AppLocalizations.of(Get.context!)!.noSensor,
    SensorKind.xiaomi: AppLocalizations.of(Get.context!)!.xiaomiSensor,
    SensorKind.kestrelDrop2: AppLocalizations.of(Get.context!)!.kestrelDrop2
  };

  void _loadSelectedSensor(){
    selectedSensor.value = _storage.read("selectedSensor") ?? SensorKind.none;
  }

  void saveSelectedSensor(){
    _storage.write("selectedSensor", selectedSensor.value);
    Get.offAllNamed('/home');
  }
}