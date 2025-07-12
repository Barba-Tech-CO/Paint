import 'package:flutter/foundation.dart';
import '../../model/auth_model.dart';
import '../../service/auth_service.dart';
import '../../utils/result/result.dart';
import '../../utils/command/command.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService) {
    _initializeCommands();
  }

  // State
  AuthState _state = AuthState.initial;
  AuthState get state => _state;

  // User data
  AuthStatusResponse? _authStatus;
  AuthStatusResponse? get authStatus => _authStatus;

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Commands
  late final Command0<void> _initializeCommand;
  late final Command0<String> _getAuthorizeUrlCommand;
  late final Command1<bool, String> _processCallbackCommand;
  late final Command0<void> _logoutCommand;
  late final Command0<AuthDebugResponse> _getDebugInfoCommand;

  Command0<void> get initializeCommand => _initializeCommand;
  Command0<String> get getAuthorizeUrlCommand => _getAuthorizeUrlCommand;
  Command1<bool, String> get processCallbackCommand => _processCallbackCommand;
  Command0<void> get logoutCommand => _logoutCommand;
  Command0<AuthDebugResponse> get getDebugInfoCommand => _getDebugInfoCommand;

  // Computed properties
  bool get isLoading =>
      _state == AuthState.loading || _initializeCommand.running;
  bool get isAuthenticated =>
      _state == AuthState.authenticated &&
      _authStatus?.data.authenticated == true;
  bool get hasError => _state == AuthState.error || _errorMessage != null;

  AuthService get authService => _authService;

  void _initializeCommands() {
    _initializeCommand = Command0(() async {
      _setState(AuthState.loading);
      _clearError();

      try {
        final result = await _authService.getStatus();
        return result.when(
          ok: (status) {
            _authStatus = status;
            if (status.data.authenticated && !status.data.needsLogin) {
              _setState(AuthState.authenticated);
            } else {
              _setState(AuthState.unauthenticated);
            }
            return Result.ok(null);
          },
          error: (error) {
            _setError(error.toString());
            _setState(AuthState.unauthenticated);
            return Result.error(error);
          },
        );
      } catch (e) {
        _setError(e.toString());
        _setState(AuthState.error);
        return Result.error(Exception(e.toString()));
      }
    });

    _getAuthorizeUrlCommand = Command0(() async {
      try {
        final result = await _authService.getAuthorizeUrl();
        return result.when(
          ok: (url) => Result.ok(url),
          error: (error) => Result.error(error),
        );
      } catch (e) {
        return Result.error(Exception(e.toString()));
      }
    });

    _processCallbackCommand = Command1((String code) async {
      _setState(AuthState.loading);
      _clearError();

      try {
        final result = await _authService.processCallback(code);
        return result.when(
          ok: (response) {
            // Atualiza o status após o callback
            _initializeCommand.execute();
            return Result.ok(true);
          },
          error: (error) {
            _setError(error.toString());
            _setState(AuthState.unauthenticated);
            return Result.ok(false);
          },
        );
      } catch (e) {
        _setError(e.toString());
        _setState(AuthState.error);
        return Result.ok(false);
      }
    });

    _logoutCommand = Command0(() async {
      _setState(AuthState.loading);
      _clearError();

      try {
        // Simula logout limpando o status
        _authStatus = null;
        _setState(AuthState.unauthenticated);
        return Result.ok(null);
      } catch (e) {
        _setError(e.toString());
        return Result.error(Exception(e.toString()));
      }
    });

    _getDebugInfoCommand = Command0(() async {
      try {
        final result = await _authService.getDebugInfo();
        return result.when(
          ok: (info) => Result.ok(info),
          error: (error) => Result.error(error),
        );
      } catch (e) {
        return Result.error(Exception(e.toString()));
      }
    });
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Public methods
  Future<void> initializeAuth() async {
    await _initializeCommand.execute();
  }

  Future<String> getAuthorizeUrl() async {
    await _getAuthorizeUrlCommand.execute();
    final result = _getAuthorizeUrlCommand.result;
    if (result != null) {
      return result.when(
        ok: (url) => url,
        error: (error) => throw error,
      );
    }
    throw Exception('Failed to get authorize URL');
  }

  Future<bool> processCallback(String code) async {
    await _processCallbackCommand.execute(code);
    final result = _processCallbackCommand.result;
    if (result != null) {
      return result.when(
        ok: (success) => success,
        error: (error) => false,
      );
    }
    return false;
  }

  Future<void> logout() async {
    await _logoutCommand.execute();
  }

  Future<AuthDebugResponse> getDebugInfo() async {
    await _getDebugInfoCommand.execute();
    final result = _getDebugInfoCommand.result;
    if (result != null) {
      return result.when(
        ok: (info) => info,
        error: (error) => throw error,
      );
    }
    throw Exception('Failed to get debug info');
  }
}
