import 'package:flutter/foundation.dart';
import '../../utils/result/result.dart';
import '../../model/auth_model.dart';
import '../../service/auth_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthDebugData? _profileData;
  bool _isLoading = false;
  String? _error;

  ProfileViewModel(this._authService);

  // Getters
  AuthDebugData? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Obtém informações de debug/perfil
  Future<void> getProfileInfo() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.getDebugInfo();
      if (result is Ok) {
        final response = result.asOk.value;
        _profileData = response.data;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Erro ao obter informações do perfil: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém informações do token
  String get tokenInfo {
    if (_profileData == null) return 'Nenhuma informação disponível';
    return 'Total: ${_profileData!.totalTokens}, Válidos: ${_profileData!.valid}, Expirados: ${_profileData!.expired}';
  }

  /// Obtém informações da conta
  String get accountInfo {
    if (_profileData == null) return 'Nenhuma informação disponível';
    return 'Tokens válidos: ${_profileData!.valid}';
  }

  /// Obtém informações de configuração
  String get configInfo {
    if (_profileData == null) return 'Nenhuma informação disponível';
    return 'Total de tokens: ${_profileData!.totalTokens}';
  }

  /// Verifica se há tokens válidos
  bool get hasValidTokens {
    if (_profileData == null) return false;
    return _profileData!.valid > 0;
  }

  /// Obtém a quantidade de tokens válidos
  int get validTokensCount {
    if (_profileData == null) return 0;
    return _profileData!.valid;
  }

  /// Obtém a quantidade de tokens expirados
  int get expiredTokensCount {
    if (_profileData == null) return 0;
    return _profileData!.expired;
  }

  /// Obtém o total de tokens
  int get totalTokensCount {
    if (_profileData == null) return 0;
    return _profileData!.totalTokens;
  }

  /// Limpa os dados do perfil
  void clearProfile() {
    _profileData = null;
    _clearError();
    notifyListeners();
  }

  // Métodos privados para gerenciar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
