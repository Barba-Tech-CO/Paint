import 'dart:async';

import '../../service/deep_link_service.dart';

class DeepLinkHandler {
  final DeepLinkService _deepLinkService;
  final void Function(Uri) onDeepLink;
  StreamSubscription? _subscription;

  DeepLinkHandler(
    this._deepLinkService,
    this.onDeepLink,
  );

  void initialize() {
    _subscription = _deepLinkService.deepLinkStream.listen((uri) {
      onDeepLink(uri);
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
