import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPopupScreen extends StatefulWidget {
  final String popupUrl;
  const WebViewPopupScreen({super.key, required this.popupUrl});

  @override
  State<WebViewPopupScreen> createState() => _WebViewPopupScreenState();
}

class _WebViewPopupScreenState extends State<WebViewPopupScreen> {
  late final WebViewController _popupController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _popupController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white);

    // Configure navigation delegate with error handling
    try {
      _popupController.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // Check if 2FA is completed and user should be redirected back
            if (_shouldCloseModal(request.url)) {
              // Close the modal after a short delay to allow the page to load
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  context.pop(request.url);
                }
              });
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            // Handle WebView errors, especially on iOS
            log('WebView error: ${error.description}');
          },
          onPageStarted: (url) {
            log('[WebViewPopup] Page started: $url');
          },
          onPageFinished: (url) {
            log('[WebViewPopup] Page finished: $url');
          },
        ),
      );
    } catch (e) {
      log('[WebViewPopup] Error setting navigation delegate: $e');
    }

    // iOS-specific configuration
    if (Platform.isIOS) {
      try {
        _popupController.setUserAgent(
          'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
        );
      } catch (e) {
        log('[WebViewPopup] Error setting user agent: $e');
      }
    }

    // Load the URL
    try {
      _popupController.loadRequest(Uri.parse(widget.popupUrl));
    } catch (e) {
      log('[WebViewPopup] Error loading URL: $e');
    }
  }

  bool _shouldCloseModal(String url) {
    // Check for various patterns that indicate successful authentication/2FA completion
    if (url.contains('marketplace.gohighlevel.com/auth/chooselocation') ||
        url.contains('app.gohighlevel.com/location/') ||
        url.contains('/enauth/chooselocation') ||
        url.contains('dashboard') ||
        url.contains('locations')) {
      log('[WebViewPopup] Should close modal for: $url');
      return true;
    }
    
    // Also close if returning to the main app domain (indicating completion)
    if (url.contains('paintpro.barbatech.company')) {
      log('[WebViewPopup] Should close modal - returning to app domain: $url');
      return true;
    }
    
    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoHighLevel Login'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: WebViewWidget(
        controller: _popupController,
      ),
    );
  }
}
