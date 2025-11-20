import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityNotifier extends ValueNotifier<bool> {
  ConnectivityNotifier._() : super(true);

  static final ConnectivityNotifier instance = ConnectivityNotifier._();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> initialize() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    value = _isOnline(result);

    _subscription ??= connectivity.onConnectivityChanged.listen((results) {
      value = _isOnline(results);
    });
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
