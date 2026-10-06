import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_backend.dart';
import '../data/backend_contract.dart';
import '../data/mock_backend.dart';

/// Immutable wrapper so Riverpod sees a new state on every backend change
/// (the backend itself is a mutable singleton).
class StoreState {
  const StoreState(this.backend, this.rev);
  final BackendContract backend;
  final int rev;
}

/// Build with `--dart-define=NEEDY_USE_API=true` to run against the real
/// Django backend; default (and all tests) use the offline mock.
const bool kUseApi =
    bool.fromEnvironment('NEEDY_USE_API') || bool.fromEnvironment('NEEDY_API_URL');

/// Single app-wide store provider. Screens watch [storeProvider] and call
/// methods on `.backend`; every mutation notifies and rev++.
class StoreNotifier extends Notifier<StoreState> {
  @override
  StoreState build() {
    final BackendContract backend = kUseApi ? ApiBackend() : MockBackend();
    var rev = 0;
    backend.addListener(() {
      rev += 1;
      state = StoreState(backend, rev);
    });
    return StoreState(backend, rev);
  }

  BackendContract get b => state.backend;
}

final storeProvider =
    NotifierProvider<StoreNotifier, StoreState>(StoreNotifier.new);
