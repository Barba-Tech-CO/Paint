import '../../model/user_model.dart';
import '../../utils/result/result.dart';

abstract class IUserRepository {
  Future<Result<UserModel>> getUser();
}
