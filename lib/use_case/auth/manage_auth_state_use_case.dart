import '../../model/models.dart';
import '../../utils/result/result.dart';

/// UseCase unificado para gerenciar estado de autenticação
class ManageAuthStateUseCase {
  /// Define estado de carregamento
  Future<Result<bool>> setLoading(
    bool loading,
    Function(bool) setLoadingCallback,
  ) async {
    setLoadingCallback(loading);
    return Result.ok(loading);
  }

  /// Define mensagem de erro
  Future<Result<String>> setError(
    String error,
    Function(String) setErrorCallback,
  ) async {
    setErrorCallback(error);
    return Result.ok(error);
  }

  /// Limpa mensagem de erro
  Future<Result<void>> clearError(Function() clearErrorCallback) async {
    clearErrorCallback();
    return Result.ok(null);
  }

  /// Define estado de autenticação
  Future<Result<AuthState>> setState(
    AuthState state,
    Function(AuthState) setStateCallback,
  ) async {
    setStateCallback(state);
    return Result.ok(state);
  }

  /// Reseta estado para inicial
  Future<Result<AuthState>> reset(Function() resetCallback) async {
    resetCallback();
    return Result.ok(AuthState.initial);
  }

  /// Executa operação com loading automático
  Future<Result<T>> executeWithLoading<T>({
    required Future<Result<T>> Function() operation,
    required Function(bool) setLoadingCallback,
    required Function(String) setErrorCallback,
    required Function() clearErrorCallback,
  }) async {
    // Inicia loading
    await setLoading(true, setLoadingCallback);
    await clearError(clearErrorCallback);

    // Executa operação
    final result = await operation();

    // Finaliza loading
    await setLoading(false, setLoadingCallback);

    // Trata erro se necessário
    result.when(
      ok: (_) {},
      error: (error) => setError(error.toString(), setErrorCallback),
    );

    return result;
  }
}
