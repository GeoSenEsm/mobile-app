import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:survey_frontend/domain/external_services/sensor_mac_service.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class SensorsController extends ControllerBase {
  final Rx<String> selectedSensor = Rx<String>(SensorKind.none);
  Rx<String?> kestrelId = Rx<String?>(null);
  Rx<String?> xiaomiId = Rx<String?>(null);
  Rx<String?> xiaomiMac = Rx<String?>(null);
  final GetStorage _storage;
  final SensorMacService _sensorService;
  final RxBool loadingMac = false.obs;
  final RxBool loadingMacFailed = false.obs;
  final RxBool macNotFound = false.obs;
  late TextEditingController xiaomiMacController;
  late FocusNode xiaomiFocusNode;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool get noXiaomiID => xiaomiId.value == null;
  bool get foundXiaomiMac => (!loadingMac.value &&
      !loadingMacFailed.value &&
      !macNotFound.value &&
      xiaomiId.value != null);
  bool get canSaveXiaomi =>
      selectedSensor.value == SensorKind.xiaomi &&
      (foundXiaomiMac || noXiaomiID);
  bool get canSaveKestrel =>
      selectedSensor.value == SensorKind.kestrelDrop2 &&
      (kestrelId.value != null);
  bool get canSaveNone => selectedSensor.value == SensorKind.none;
  bool get canSaveManual => selectedSensor.value == SensorKind.manual;

  // Set when the respondent's current sensor was assigned by an admin using a
  // type this screen doesn't know how to configure manually (e.g. a
  // profile-driven type such as pc_60fw). Kept unchanged and selectable so the
  // dropdown never binds to a value missing from `possibleOptions`.
  String? _externallyAssignedKind;
  bool get canSaveExternallyAssigned =>
      _externallyAssignedKind != null &&
      selectedSensor.value == _externallyAssignedKind;

  SensorsController(this._storage, this._sensorService) {
    _loadSelectedSensor();
  }

  final List<String> _legacyOptions = [
    SensorKind.none,
    SensorKind.manual,
    SensorKind.xiaomi,
    SensorKind.kestrelDrop2
  ];

  List<String> get possibleOptions => _externallyAssignedKind == null
      ? _legacyOptions
      : [..._legacyOptions, _externallyAssignedKind!];

  final Map<String, String> _legacyOptionsDisplays = {
    SensorKind.none: AppLocalizations.of(Get.context!)!.noSensor,
    SensorKind.manual: AppLocalizations.of(Get.context!)!.manualSensor,
    SensorKind.xiaomi: AppLocalizations.of(Get.context!)!.xiaomiSensor,
    SensorKind.kestrelDrop2: AppLocalizations.of(Get.context!)!.kestrelDrop2
  };

  String displayNameFor(String option) =>
      _legacyOptionsDisplays[option] ??
      getAppLocalizations().assignedByAdministrator;

  @override
  void onInit() {
    super.onInit();
    xiaomiMacController = TextEditingController(text: xiaomiMac.value);
    xiaomiFocusNode = FocusNode();

    xiaomiMac.listen((value) {
      xiaomiMacController.text = value ?? '';
    });

    xiaomiFocusNode.addListener(() {
      if (!xiaomiFocusNode.hasFocus) {
        getXiaomiMac();
        formKey.currentState?.validate();
      }
    });
  }

  @override
  void onClose() {
    xiaomiMacController.dispose();
    super.onClose();
  }

  void getXiaomiMac() async {
    if (loadingMac.value) return;
    loadingMac.value = true;
    loadingMacFailed.value = false;
    macNotFound.value = false;
    try {
      if (xiaomiId.value == null || xiaomiId.value!.isEmpty) {
        xiaomiMac.value = null;
        return;
      }
      final result = await _sensorService.getMacAddress(xiaomiId.value!);

      if (result.statusCode == 404) {
        macNotFound.value = true;
        xiaomiMac.value = null;
        return;
      }

      if (result.statusCode == 200) {
        xiaomiMac.value = result.body;
        return;
      }
      loadingMacFailed.value = true;
    } on Exception catch (e) {
      loadingMacFailed.value = true;
      Sentry.captureException(e);
    } finally {
      loadingMac.value = false;
    }
  }

  void _loadSelectedSensor() {
    try {
      selectedSensor.value = _storage.read("selectedSensor") ?? SensorKind.none;
      if (!_legacyOptions.contains(selectedSensor.value)) {
        _externallyAssignedKind = selectedSensor.value;
      }
      if (selectedSensor.value == SensorKind.xiaomi) {
        xiaomiId.value = _storage.read("selectedSensorId");
        // A prior admin-driven assignment may have left a MAC under the
        // shared `selectedSensorMac` key; surface it too so the field isn't
        // blank when the respondent re-opens this screen.
        xiaomiMac.value =
            _storage.read("xiaomiMac") ?? _storage.read("selectedSensorMac");
      }
      if (selectedSensor.value == SensorKind.kestrelDrop2) {
        kestrelId.value = _storage.read<Object>("selectedSensorId").toString();
      }
    } on Exception catch (e) {
      Sentry.captureException(e);
    }
  }

  void saveSelectedSensor() {
    bool canSave = canSaveKestrel ||
        canSaveXiaomi ||
        canSaveNone ||
        canSaveManual ||
        canSaveExternallyAssigned;
    if (!canSave) {
      return;
    }

    if (!canSaveExternallyAssigned) {
      _storage.write("selectedSensor", selectedSensor.value);
      // `selectedSensorMac` is only meaningful for admin-driven assignments;
      // a manual pick here must not keep matching against a stale MAC left
      // over from a previous assignment (see sensor_connection_factory.dart).
      _storage.remove('selectedSensorMac');
      _storage.remove('selectedSensorId');
      _storage.remove('xiaomiMac');
      if (selectedSensor.value == SensorKind.kestrelDrop2) {
        _storage.write('selectedSensorId', kestrelId.value.toString());
      }
      if (selectedSensor.value == SensorKind.xiaomi) {
        _storage.write('selectedSensorId', xiaomiId.value);
        _storage.write('xiaomiMac', xiaomiMac.value);
      }
    }
    Get.until((route) => Get.currentRoute == Routes.home);
    if (Get.currentRoute != Routes.home) {
      Get.toNamed(Routes.home);
    }
  }

  String? validateKestrel(String? value) {
    if (!canSaveKestrel) {
      return getAppLocalizations().valueNotEmpty;
    }

    return null;
  }

  String? validateXiaomi(String? value) {
    if (loadingMacFailed.value) {
      return getAppLocalizations().loadingMacFailed;
    }
    if (macNotFound.value && !loadingMac.value && xiaomiId.value != null) {
      return getAppLocalizations().sensorIdServerNotFound;
    }

    return null;
  }
}
