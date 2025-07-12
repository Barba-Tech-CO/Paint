import 'package:dio/dio.dart';
import '../utils/result/result.dart';
import '../model/auth_model.dart';
import 'http_service.dart';

class AuthService {
  final HttpService _httpService;

  AuthService(this._httpService);

  /// Verifica o status de autenticação
  Future<Result<AuthStatusResponse>> getStatus() async {
    try {
      final response = await _httpService.get('/auth/status');
      final authStatus = AuthStatusResponse.fromJson(response.data);
      return Result.ok(authStatus);
    } catch (e) {
      return Result.error(Exception('Erro ao verificar status: $e'));
    }
  }

  /// Obtém a URL de autorização
  Future<Result<String>> getAuthorizeUrl() async {
    try {
      final response = await _httpService.get(
        '/auth/authorize-url',
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

      // Se a resposta não for um redirecionamento, algo está errado
      return Result.error(
        Exception(
          'A resposta do servidor não foi um redirecionamento esperado.',
        ),
      );
    } catch (e) {
      return Result.error(Exception('Erro ao obter URL de autorização: $e'));
    }
  }

  /// Processa o callback de autorização
  Future<Result<AuthRefreshResponse>> processCallback(String code) async {
    try {
      final response = await _httpService.post(
        '/auth/callback',
        data: {
          'code': code,
        },
      );
      final callbackResponse = AuthRefreshResponse.fromJson(response.data);
      return Result.ok(callbackResponse);
    } catch (e) {
      return Result.error(Exception('Erro no callback: $e'));
    }
  }

  /// Renova o token de acesso
  Future<Result<AuthRefreshResponse>> refreshToken() async {
    try {
      final response = await _httpService.post('/auth/refresh', data: {});
      final refreshResponse = AuthRefreshResponse.fromJson(response.data);
      return Result.ok(refreshResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao renovar token: $e'));
    }
  }

  /// Obtém informações de debug
  Future<Result<AuthDebugResponse>> getDebugInfo() async {
    try {
      final response = await _httpService.get('/auth/debug');
      final debugResponse = AuthDebugResponse.fromJson(response.data);
      return Result.ok(debugResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao obter debug info: $e'));
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
        return Result.error(Exception('Erro ao verificar autenticação'));
      }
    } catch (e) {
      return Result.error(Exception('Erro ao verificar autenticação: $e'));
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

        final now = DateTime.now();
        final expiresAt = status.data.expiresAt!;
        final difference = expiresAt.difference(now);

        return Result.ok(difference.inMinutes < 60);
      } else {
        return Result.error(Exception('Erro ao verificar expiração do token'));
      }
    } catch (e) {
      return Result.error(
        Exception('Erro ao verificar expiração do token: $e'),
      );
    }
  }
}
