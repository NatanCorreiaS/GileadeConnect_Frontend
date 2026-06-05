import 'dart:async';

import 'package:app_links/app_links.dart';

enum CheckoutResult { success, failure, pending }

typedef CheckoutResultCallback = void Function(CheckoutResult result);

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._();

  factory DeepLinkService() => _instance;

  DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  CheckoutResult? _pendingResult;
  final List<CheckoutResultCallback> _listeners = [];

  void addListener(CheckoutResultCallback callback) {
    _listeners.add(callback);

    final pending = _pendingResult;
    if (pending != null) {
      _pendingResult = null;
      for (final listener in _listeners) {
        listener(pending);
      }
      _listeners.clear();
    }
  }

  void removeListener(CheckoutResultCallback callback) {
    _listeners.remove(callback);
  }

  Future<void> init() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    _sub = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  CheckoutResult? consumePendingResult() {
    final result = _pendingResult;
    _pendingResult = null;
    return result;
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme != 'gileadeconnect') return;

    final path = uri.path;

    if (path.startsWith('/checkout')) {
      final segments = path.split('/');
      if (segments.length >= 3) {
        final status = segments[2];
        final result = _parseCheckoutResult(status);

        if (_listeners.isNotEmpty) {
          for (final listener in List<CheckoutResultCallback>.from(_listeners)) {
            listener(result);
          }
          _listeners.clear();
        } else {
          _pendingResult = result;
        }
      }
    }
  }

  CheckoutResult _parseCheckoutResult(String status) {
    switch (status) {
      case 'success':
        return CheckoutResult.success;
      case 'failure':
        return CheckoutResult.failure;
      case 'pending':
        return CheckoutResult.pending;
      default:
        return CheckoutResult.pending;
    }
  }

  void dispose() {
    _sub?.cancel();
    _listeners.clear();
  }
}
