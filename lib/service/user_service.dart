import '../model/user_model.dart';
import '../utils/logger/app_logger.dart';
import '../utils/result/result.dart';
import 'auth_service_exception.dart';
import 'services.dart';

class UserService {
  final HttpService _httpService;
  final AppLogger _logger;

  UserService(this._httpService, this._logger);

  /// Gets complete user data including GHL information if applicable
  Future<Result<UserModel>> getUser() async {
    try {
      final response = await _httpService.get('/user');
      final user = UserModel.fromJson(response.data);
      
      // Log user status for debugging
      if (user.ghlDataIncomplete == true) {
        _logger.warning('[UserService] User has incomplete GHL data');
      }
      if (user.ghlError == true) {
        _logger.warning('[UserService] User has GHL error');
      }
      
      _logger.info('[UserService] User data retrieved: ${user.name}, GHL User: ${user.isGhlUser}');
      return Result.ok(user);
    } on AuthServiceException catch (e) {
      _logger.info(
        '[UserService] Authentication service unavailable: ${e.message}',
      );
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
