import 'dart:developer';

import '../model/user_model.dart';
import '../utils/logger/app_logger.dart';
import '../utils/result/result.dart';
import 'services.dart';

class UserService {
  final HttpService _httpService;
  final AppLogger _logger;

  UserService(this._httpService, this._logger);

  /// Gets complete user data including GHL information if applicable
  Future<Result<UserModel>> getUser() async {
    try {
      final response = await _httpService.get('api/user');
      final user = UserModel.fromJson(response.data);
      log('[UserService] User data: ${user.toJson()}');
      return Result.ok(user);
    } catch (e) {
      _logger.error('Error getting user data: $e');
      return Result.error(
        Exception('Error getting user data: $e'),
      );
    }
  }
}