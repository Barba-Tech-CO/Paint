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
      if (response.statusCode == 401) {
        return Result.error(
          AuthServiceException(
            message: 'Authentication required',
            errorType: AuthServiceErrorType.invalidCredentials,
            technicalDetails: 'GET /user returned 401',
          ),
        );
      }

      if (response.statusCode != 200) {
        return Result.error(
          Exception('Failed to load user data: ${response.statusCode}'),
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return Result.error(
          Exception('Unexpected user payload format'),
        );
      }

      final user = UserModel.fromJson(data);
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
