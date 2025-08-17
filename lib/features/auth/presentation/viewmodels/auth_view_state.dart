import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/auth_state.dart';

class AuthViewState {
  final AuthState state;
  final bool isLoading;
  final String? errorMessage;
  final AuthEntity? authStatus;
  final String? authorizeUrl;
  final bool shouldShowPopup;
  final String? popupUrl;

  const AuthViewState({
    required this.state,
    required this.isLoading,
    this.errorMessage,
    this.authStatus,
    this.authorizeUrl,
    this.shouldShowPopup = false,
    this.popupUrl,
  });

  factory AuthViewState.initial() => const AuthViewState(
    state: AuthState.initial,
    isLoading: false,
    errorMessage: null,
    authStatus: null,
    authorizeUrl: null,
    shouldShowPopup: false,
    popupUrl: null,
  );

  AuthViewState copyWith({
    AuthState? state,
    bool? isLoading,
    String? errorMessage,
    AuthEntity? authStatus,
    String? authorizeUrl,
    bool? shouldShowPopup,
    String? popupUrl,
  }) {
    return AuthViewState(
      state: state ?? this.state,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      authStatus: authStatus ?? this.authStatus,
      authorizeUrl: authorizeUrl ?? this.authorizeUrl,
      shouldShowPopup: shouldShowPopup ?? this.shouldShowPopup,
      popupUrl: popupUrl ?? this.popupUrl,
    );
  }
}
