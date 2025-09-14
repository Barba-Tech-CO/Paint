import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../model/auth_model/auth_state.dart';
import '../utils/logger/app_logger.dart';
import '../viewmodel/auth/auth_viewmodel.dart';
import '../view/auth/marketplace_popup_helper.dart';

class AuthWebViewService {
  final AppLogger _logger;

  AuthWebViewService(this._logger);

  WebViewController createController({
    required String url,
    required AuthViewModel authViewModel,
    required BuildContext context,
    required bool Function() onMountedCheck,
    required bool Function() isDisposedCheck,
  }) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            return await _handleNavigationRequest(
              request,
              authViewModel,
              context,
              onMountedCheck,
              isDisposedCheck,
            );
          },
          onPageStarted: (url) {
            if (onMountedCheck() && !isDisposedCheck()) {
              authViewModel.setLoading(true);
            }
          },
          onPageFinished: (url) {
            if (onMountedCheck() && !isDisposedCheck()) {
              authViewModel.setLoading(false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    return controller;
  }

  Future<NavigationDecision> _handleNavigationRequest(
    NavigationRequest request,
    AuthViewModel authViewModel,
    BuildContext context,
    bool Function() onMountedCheck,
    bool Function() isDisposedCheck,
  ) async {
    // Check if this is the OAuth callback URL (supports both dev and prod)
    final isCallbackUrl =
        request.url.contains('/api/auth/callback') &&
        (request.url.contains('paintpro.barbatech.company') ||
            request.url.contains('localhost:8080') ||
            request.url.contains('localhost:8090') ||
            request.url.contains('10.0.2.2:8080'));

    if (isCallbackUrl) {
      return await _handleOAuthCallback(
        request,
        authViewModel,
        context,
        onMountedCheck,
        isDisposedCheck,
      );
    }

    // Handle marketplace popup
    if (request.url.startsWith(
      'https://app.gohighlevel.com/?src=marketplace',
    )) {
      if (onMountedCheck() && !isDisposedCheck()) {
        MarketplacePopupHelper.show(
          context,
          request.url,
          authViewModel,
        );
      }
      return NavigationDecision.prevent;
    }

    // Let other navigation proceed normally
    return NavigationDecision.navigate;
  }

  Future<NavigationDecision> _handleOAuthCallback(
    NavigationRequest request,
    AuthViewModel authViewModel,
    BuildContext context,
    bool Function() onMountedCheck,
    bool Function() isDisposedCheck,
  ) async {
    // Extract the code and process it through the proper OAuth flow
    final uri = Uri.parse(request.url);
    final code = uri.queryParameters['code'];

    if (code != null) {
      try {
        // Use the proper OAuth flow through AuthViewModel
        await authViewModel.processCallback(code);

        // Only navigate if processing was successful and state is authenticated
        if (onMountedCheck() &&
            !isDisposedCheck() &&
            authViewModel.state.state == AuthState.authenticated) {
          GoRouter.of(context).go('/home');
        } else if (authViewModel.state.isError) {
          // Error state will be handled by the Consumer widget in build method
          _logger.error(
            '[AuthWebViewService] Error ${authViewModel.state.errorMessage}',
          );
        }
      } catch (e) {
        _logger.error(
          '[AuthWebViewService] Error processing OAuth callback: $e',
        );
        authViewModel.handleError(
          'Error completing authentication: $e',
        );
      }
    } else {
      _logger.error('[AuthWebViewService] No code found in callback URL');
    }

    // Prevent navigation to avoid webview SSL issues
    return NavigationDecision.prevent;
  }
}
