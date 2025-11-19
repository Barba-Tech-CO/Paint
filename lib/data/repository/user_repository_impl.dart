import '../../domain/repository/user_repository.dart';
import '../../model/user_model.dart';
import '../../service/user_service.dart';
import '../../utils/result/result.dart';

class UserRepositoryImpl implements IUserRepository {
  final UserService _userService;

  UserRepositoryImpl(this._userService);

  @override
  Future<Result<UserModel>> getUser() async {
    return await _userService.getUser();
  }
}
