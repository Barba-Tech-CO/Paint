import '../../model/auth_state.dart';
import '../../service/logger_service.dart';
import '../../utils/result/result.dart';
import 'auth_use_cases.dart';

/// UseCase unificado para lidar com Deep Links de autenticação
class HandleDeepLinkUseCase {
  final AuthOperationsUseCase _authOperationsUseCase;
  final ManageAuthStateUseCase _manageAuthStateUseCase;

  HandleDeepLinkUseCase(
    this._authOperationsUseCase,
    this._manageAuthStateUseCase,
  );

  /// Lida com sucesso na autenticação via Deep Link
  Future<Result<void>> handleSuccess() async {
    LoggerService.info(
      '[HandleDeepLinkUseCase] Autenticação bem-sucedida via Deep Link!',
    );

    await _manageAuthStateUseCase.clearError(() {});
    await _authOperationsUseCase.checkAuthStatus();

    return Result.ok(null);
  }

  /// Lida com erro na autenticação via Deep Link
  Future<Result<void>> handleError(String error) async {
    LoggerService.error('[HandleDeepLinkUseCase] Erro na autenticação: $error');

    await _manageAuthStateUseCase.setState(AuthState.error, (state) {});
    await _manageAuthStateUseCase.setError(error, (error) {});

    return Result.ok(null);
  }

  /// Lida com erro genérico no Deep Link
  Future<Result<void>> handleGenericError() async {
    return handleError('Erro ao processar callback de autenticação');
  }
}
