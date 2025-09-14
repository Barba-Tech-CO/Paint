import '../model/user_model.dart';
import '../utils/logger/app_logger.dart';
import '../utils/result/result.dart';
import 'auth_service_exception.dart';
import 'http_service.dart';

class UserService {
  final HttpService _httpService;
  final AppLogger _logger;

  UserService(this._httpService, this._logger);

  /// Gets complete user data including GHL information if applicable
  Future<Result<UserModel>> getUser() async {
    try {
      final response = await _httpService.get('/user');
      final user = UserModel.fromJson(response.data);
      return Result.ok(user);
    } on AuthServiceException catch (e) {
      _logger.error('[UserService] Technical details: ${e.technicalDetails}');
      return Result.error(
        Exception(e.message),
      );
    } catch (e) {
      _logger.error('Error getting user data: $e');
      return Result.error(
        Exception('Error getting user data: $e'),
      );
    }
  }
}
