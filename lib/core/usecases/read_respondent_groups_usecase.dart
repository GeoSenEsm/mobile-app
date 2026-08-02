import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/domain/models/respondent_group_dto.dart';

abstract class ReadResopndentGroupdUseCase {
  Future<List<RespondentGroupDto>> getAll();
}

class ReadResopndentGroupdUseCaseImpl implements ReadResopndentGroupdUseCase {
  final GetStorage _storage;

  ReadResopndentGroupdUseCaseImpl(this._storage);

  @override
  Future<List<RespondentGroupDto>> getAll() {
    final result = _storage.read<List<dynamic>>('groups');
    if (result == null) {
      return Future.value([]);
    }

    return Future.value(result.map((e) {
      if (e.runtimeType == RespondentGroupDto) {
        return e as RespondentGroupDto;
      }

      return RespondentGroupDto.fromJson(e);
    }).toList());
  }
}
