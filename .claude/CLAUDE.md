# Flutter MVVM Specialist - HTTP 500 Login Error Handling Implementation

## Context & Problem Statement

You are a Flutter specialist working with MVVM architecture. The application "Paint Estimator" is experiencing HTTP 500 errors during authentication flow due to external service blocking (GHL account issues). We need to implement proper error handling to gracefully manage these server errors without exposing technical details to end users.

## Current Architecture Overview

Based on the existing codebase structure:

```
Services/
├── AuthService (processCallback method)
├── HttpService (GET/POST requests)
└── UserService (getUser method)

Use Cases/
└── AuthOperationsUseCase (checkAuthStatus, processCallback)

ViewModels/
├── AuthViewModel (_processCallback)
└── UserViewModel (fetchUser)

Views/
├── AuthWebView (OAuth flow)
└── HomeView (post-authentication)

Persistence/
└── AuthPersistenceService (token management)
```

## 🎯 SCOPE LIMITATIONS - READ CAREFULLY

### What TO Modify:

- ✅ HTTP error handling logic in services
- ✅ Error state management in ViewModels
- ✅ Error display logic in authentication views
- ✅ Logging mechanisms for HTTP 500 errors
- ✅ User-facing error messages
- ✅ Retry mechanisms for failed authentication

### What NOT TO Modify:

- ❌ Successful authentication flows
- ❌ UI components unrelated to error states
- ❌ Database operations
- ❌ Routing/navigation logic (except preventing navigation on errors)
- ❌ Third-party integrations
- ❌ Performance optimizations
- ❌ Code style improvements unrelated to error handling
- ❌ Any functionality working correctly

### Target Error Scenario ONLY:

- **Specific Error**: HTTP 500 responses from authentication endpoints
- **Specific Endpoints**: `/auth/callback` and `/api/user`
- **Specific Cause**: GHL account blocking (external service issue)
- **Specific Goal**: Graceful degradation instead of app crashes

---

## Current Error Behavior (TO FIX)

The app currently crashes/shows technical errors when receiving HTTP 500 from these endpoints:

- `GET /auth/callback?code={oauth_code}` → HTTP 500
- `GET /api/user` → HTTP 500

**Current Error Logs:**

```
⛔ [AuthService] Error processing OAuth callback: DioException [bad response]:
This exception was thrown because the response has a status code of 500
⛔ [AuthViewModel] Error processing callback: Exception: Erro no callback
⛔ Error getting user data: DioException [bad response]: status code of 500
```

## ⚠️ IMPORTANT: Code Examples Disclaimer

**ALL CODE SNIPPETS BELOW ARE ILLUSTRATIVE EXAMPLES ONLY**

- These are **conceptual examples** to show the approach and patterns
- **DO NOT copy-paste** these code blocks directly
- Use them as **reference for implementation strategy**
- **Adapt to the actual existing codebase** structure and patterns
- **Follow the existing code style** and naming conventions
- **Integrate with current architecture** rather than replacing it

The examples show **what type of logic** to implement, not the exact code to use.

---

## Required Implementation

### 1. HTTP Service Layer Enhancement

**Target File:** `package:painter_pro/service/http_service.dart`

**Requirements:**

- Detect HTTP 500 responses specifically for authentication endpoints
- Log detailed error information to console/debug only
- Return standardized error objects (not raw Dio exceptions)
- Never expose technical details to UI layer

**Implementation Pattern:**

```dart
// ⚠️ EXAMPLE ONLY - Adapt to your existing HttpService structure
class HttpService {
  Future<ApiResponse<T>> get<T>(String endpoint) async {
    try {
      // existing implementation
    } on DioException catch (e) {
      if (e.response?.statusCode == 500 && _isAuthEndpoint(endpoint)) {
        // Log technical details to console only
        logger.error('HTTP 500 on auth endpoint: $endpoint', e);

        // Return generic error for UI consumption
        return ApiResponse.error(
          message: 'Authentication service temporarily unavailable',
          errorType: AuthErrorType.serviceUnavailable
        );
      }
      // handle other errors...
    }
  }

  bool _isAuthEndpoint(String endpoint) {
    return endpoint.contains('/auth/') || endpoint.contains('/user');
  }
}
```

### 2. AuthService Enhancement

**Target File:** `package:painter_pro/service/auth_service.dart`

**Requirements:**

- Handle HTTP 500 specifically in `processCallback` method
- Prevent progression to next authentication steps
- Maintain current success flow for HTTP 200

**Implementation Focus:**

```dart
// ⚠️ EXAMPLE ONLY - Integrate with your existing AuthService
class AuthService {
  Future<AuthResult> processCallback(String code) async {
    try {
      final response = await httpService.get('/auth/callback?code=$code');

      if (response.isError && response.errorType == AuthErrorType.serviceUnavailable) {
        logger.info('[AuthService] Service unavailable, stopping auth flow');
        return AuthResult.failure(
          message: 'Unable to complete authentication at this time',
          shouldRetry: true
        );
      }

      // Continue with success flow...
    } catch (e) {
      // Existing error handling...
    }
  }
}
```

### 3. AuthViewModel State Management

**Target File:** `package:painter_pro/viewmodel/auth/auth_viewmodel.dart`

**Requirements:**

- Implement or verify `errorState` exists
- Handle HTTP 500 gracefully without navigation
- Show generic error message to user
- Provide retry mechanism

**State Management Pattern:**

```dart
// ⚠️ EXAMPLE ONLY - Modify your existing AuthViewModel
class AuthViewModel extends ChangeNotifier {
  AuthState _state = AuthState.initial();

  // Verify if this exists, if not create it:
  void setErrorState(String message, {bool canRetry = false}) {
    _state = AuthState.error(
      message: message,
      canRetry: canRetry,
      timestamp: DateTime.now()
    );
    notifyListeners();
  }

  Future<void> _processCallback(String code) async {
    try {
      _state = AuthState.loading();
      notifyListeners();

      final result = await authOperationsUseCase.processCallback(code);

      if (result.isFailure) {
        // Don't navigate, show error state instead
        setErrorState(
          result.message ?? 'Authentication failed. Please try again.',
          canRetry: true
        );
        return; // IMPORTANT: Don't proceed with navigation
      }

      // Success flow continues...
      _navigateToHome();

    } catch (e) {
      logger.error('[AuthViewModel] Unexpected error in callback processing', e);
      setErrorState('Something went wrong. Please try again.');
    }
  }
}
```

### 4. UI Error State Implementation

**Target File:** `package:painter_pro/view/auth/auth_webview.dart`

**Requirements:**

- Check if error state UI exists
- If not, create error widget with generic message
- Provide retry button
- Never show technical error details

**UI Implementation:**

```dart
// ⚠️ EXAMPLE ONLY - Adapt to your existing AuthWebView widget
class AuthWebView extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Check if error state widget exists
        if (authViewModel.state.isError) {
          return _buildErrorState(authViewModel.state.errorMessage);
        }

        // Existing WebView implementation...
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _retryAuthentication(),
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 5. Error State Model (Create if Missing)

**Create File:** `package:painter_pro/model/auth_state.dart` (if doesn't exist)

```dart
// ⚠️ EXAMPLE ONLY - Create similar structure adapted to your existing models
enum AuthStateType { initial, loading, authenticated, error }
enum AuthErrorType { serviceUnavailable, invalidCredentials, networkError, unknown }

class AuthState {
  final AuthStateType type;
  final String? errorMessage;
  final AuthErrorType? errorType;
  final bool canRetry;
  final DateTime? timestamp;

  const AuthState({
    required this.type,
    this.errorMessage,
    this.errorType,
    this.canRetry = false,
    this.timestamp,
  });

  factory AuthState.initial() => AuthState(type: AuthStateType.initial);
  factory AuthState.loading() => AuthState(type: AuthStateType.loading);
  factory AuthState.authenticated() => AuthState(type: AuthStateType.authenticated);
  factory AuthState.error(String message, {bool canRetry = false}) => AuthState(
    type: AuthStateType.error,
    errorMessage: message,
    canRetry: canRetry,
    timestamp: DateTime.now(),
  );

  bool get isError => type == AuthStateType.error;
  bool get isLoading => type == AuthStateType.loading;
  bool get isAuthenticated => type == AuthStateType.authenticated;
}
```

## Implementation Checklist

### Phase 1: Error Detection & Logging

- [ ] Modify `HttpService` to detect HTTP 500 on auth endpoints
- [ ] Implement console-only logging for technical details
- [ ] Create standardized error response objects

### Phase 2: Service Layer Updates

- [ ] Update `AuthService.processCallback()` to handle service unavailable
- [ ] Update `UserService.getUser()` with same error handling
- [ ] Ensure no raw exceptions bubble up to ViewModels

### Phase 3: ViewModel State Management

- [ ] Verify `AuthViewModel` has error state management
- [ ] Implement `setErrorState()` method if missing
- [ ] Prevent navigation on HTTP 500 errors
- [ ] Add retry mechanism

### Phase 4: UI Implementation

- [ ] Check if error state UI exists in `AuthWebView`
- [ ] Create error widget with generic messaging
- [ ] Implement retry functionality
- [ ] Test error state display

### Phase 5: Testing

- [ ] Simulate HTTP 500 responses
- [ ] Verify error state shows generic message
- [ ] Confirm technical details only in console
- [ ] Test retry functionality

## Error Messages (Generic & User-Friendly)

**For HTTP 500 on auth endpoints:**

- "Authentication service is temporarily unavailable. Please try again in a few moments."
- "Unable to complete sign-in at this time. Please try again."
- "Service temporarily unavailable. Please try again."

**Never show to users:**

- DioException details
- Stack traces
- HTTP status codes
- API endpoint URLs
- Technical error descriptions

## Success Criteria

1. ✅ HTTP 500 errors on auth endpoints don't crash the app
2. ✅ Users see friendly, generic error messages
3. ✅ Technical details logged to console only
4. ✅ Authentication flow stops gracefully on HTTP 500
5. ✅ Retry mechanism available for users
6. ✅ No navigation occurs on authentication failures
7. ✅ Error state UI is clean and professional

## Priority: CRITICAL

**Timeline:** Implement within 4 hours
**Testing:** Must handle HTTP 500 scenarios gracefully

---

## 🔴 CRITICAL REMINDERS

### Code Implementation Guidelines:

1. **EXAMPLES ARE NOT REAL CODE** - All snippets above are conceptual patterns
2. **ANALYZE EXISTING CODE FIRST** - Understand current implementation before changes
3. **MAINTAIN EXISTING PATTERNS** - Follow the established code style and architecture
4. **GRADUAL INTEGRATION** - Don't replace entire classes, modify existing methods
5. **TEST INCREMENTALLY** - Test each change before proceeding to next phase

### Implementation Strategy:

- **Step 1**: Examine existing error handling patterns in the codebase
- **Step 2**: Identify where HTTP 500 errors are currently caught
- **Step 3**: Implement changes incrementally, following existing patterns
- **Step 4**: Test each modification before moving to the next layer

**Start with Phase 1 (Error Detection) and work through each phase systematically. Focus on preventing user exposure to technical errors while maintaining good developer debugging capabilities.**
