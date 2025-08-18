import 'package:dio/dio.dart';

import '../model/auth_model.dart';
import '../utils/result/result.dart';
import 'http_service.dart';

class AuthService {
  final HttpService _httpService;
  static const String _baseUrl = '/auth';

  AuthService(this._httpService);

  /// Verifica o status de autenticação
  Future<Result<AuthStatusResponse>> getStatus() async {
    try {
      final response = await _httpService.get('$_baseUrl/status');
      final authStatus = AuthStatusResponse.fromJson(response.data);
      return Result.ok(authStatus);
    } catch (e) {
      return Result.error(
        Exception('Error checking authentication status: $e'),
      );
    }
  }

  /// Obtém a URL de autorização
  Future<Result<String>> getAuthorizeUrl() async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/authorize-url',
        // Opções especiais para esta chamada para não seguir o redirecionamento
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            // Aceita qualquer status que não seja um erro de servidor
            return status != null && status < 500;
          },
        ),
      );

      // Se a resposta for um redirecionamento, pegamos a URL do cabeçalho
      if (response.statusCode == 302) {
        final location = response.headers.value('location');
        if (location != null) {
          return Result.ok(location);
        }
      }

      // Se a resposta for 200, pode ser que o servidor retorne a URL diretamente
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('url')) {
          return Result.ok(data['url']);
        }
        if (data is String && data.startsWith('http')) {
          return Result.ok(data);
        }
      }

      // Se a resposta não for um redirecionamento, algo está errado
      return Result.error(
        Exception(
          'Server response was not the expected redirect. Status: ${response.statusCode}, Data: ${response.data}',
        ),
      );
    } catch (e) {
      return Result.error(
        Exception('Error getting authorization URL: $e'),
      );
    }
  }

  /// Processa o callback de autorização
  Future<Result<AuthRefreshResponse>> processCallback(String code) async {
    try {
      final response = await _httpService.get('$_baseUrl/callback?code=$code');
      final callbackResponse = AuthRefreshResponse.fromJson(response.data);
      return Result.ok(callbackResponse);
    } catch (e) {
      return Result.error(Exception('Error processing callback: $e'));
    }
  }

  /// Renova o token de acesso
  Future<Result<AuthRefreshResponse>> refreshToken() async {
    try {
      final response = await _httpService.post(
        '$_baseUrl/refresh',
        data: {},
      );
      final refreshResponse = AuthRefreshResponse.fromJson(response.data);
      return Result.ok(refreshResponse);
    } catch (e) {
      return Result.error(Exception('Error refreshing token: $e'));
    }
  }

  /// Verifica se está autenticado
  Future<Result<bool>> isAuthenticated() async {
    try {
      final statusResult = await getStatus();
      if (statusResult is Ok) {
        final status = statusResult.asOk.value;
        return Result.ok(status.data.authenticated && !status.data.needsLogin);
      } else {
        return Result.error(
          Exception('Error checking authentication'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error checking authentication: $e'),
      );
    }
  }

  /// Verifica se o token está próximo de expirar
  Future<Result<bool>> isTokenExpiringSoon() async {
    try {
      final statusResult = await getStatus();
      if (statusResult is Ok) {
        final status = statusResult.asOk.value;
        if (!status.data.authenticated || status.data.expiresAt == null) {
          return Result.ok(true);
        }

        // Use the isExpiringSoon field from the API response if available
        if (status.data.isExpiringSoon != null) {
          return Result.ok(status.data.isExpiringSoon!);
        }

        // Fallback to manual calculation
        final now = DateTime.now();
        final expiresAt = status.data.expiresAt!;
        final difference = expiresAt.difference(now);

        return Result.ok(difference.inMinutes < 60);
      } else {
        return Result.error(
          Exception('Error checking token expiration'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error checking token expiration: $e'),
      );
    }
  }

  /// Obtém o location_id atual
  Future<Result<String?>> getCurrentLocationId() async {
    try {
      final statusResult = await getStatus();
      if (statusResult is Ok) {
        final status = statusResult.asOk.value;
        return Result.ok(status.data.locationId);
      } else {
        return Result.error(
          Exception('Error getting location_id'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error getting location_id: $e'),
      );
    }
  }
}
