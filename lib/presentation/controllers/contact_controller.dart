import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/domain/external_services/phone_contact_service.dart';
import 'package:survey_frontend/domain/models/phone_contact_dto.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:url_launcher/url_launcher.dart';


class ContactController extends ControllerBase {
  final RxBool isLoadingContacts = false.obs;
  final RxBool loadingError = false.obs;
  final PhoneContactService _phoneContactService;
  final RxList<PhoneContactDto> contacts = <PhoneContactDto>[].obs;

  ContactController(this._phoneContactService);

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  void loadContacts() async {
    if (isLoadingContacts.value) return;

    try{
      isLoadingContacts.value = true;
      loadingError.value = false;
      contacts.clear();
      final contactsResult = await _phoneContactService.getContacts();

      if (contactsResult.error != null || contactsResult.statusCode != 200) {
        loadingError.value = true;
        Sentry.captureException(contactsResult.error);
        return;
      }

      contacts.addAll(contactsResult.body!);
    } catch (e){
      Sentry.captureException(e);
      loadingError.value = true;
    } finally {
      isLoadingContacts.value = false;
    }
  }

  void call(PhoneContactDto contact) async {
    try{
      if (!await launchUrl(Uri.parse("tel://${contact.number}"))){
        _couldNotCall();
      }
    } catch (e){
      _couldNotCall();
      Sentry.captureException(e);
    }
  }

  void _couldNotCall(){
    Get.rawSnackbar(message: getAppLocalizations().couldNotMakeCall);
  }
}