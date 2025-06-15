import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/phone_contact_service.dart';
import 'package:survey_frontend/domain/models/phone_contact_dto.dart';

class PhoneContactServiceImpl extends APIServiceBase
    implements PhoneContactService {
  PhoneContactServiceImpl(super.dio, {super.tokenProvider});

  @override
  Future<APIResponse<List<PhoneContactDto>>> getContacts() {
    return get<List<PhoneContactDto>>(
        '/api/phonenumber',
        (dynamic items) => items
            .map<PhoneContactDto>((e) => PhoneContactDto.fromJson(e))
            .toList());
  }
}
