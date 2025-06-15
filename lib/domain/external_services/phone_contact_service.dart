import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/models/phone_contact_dto.dart';

abstract class PhoneContactService {
  Future<APIResponse<List<PhoneContactDto>>> getContacts();
}