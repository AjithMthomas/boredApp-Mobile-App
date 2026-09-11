import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_backend.dart';

/// Immutable wrapper so Riverpod sees a new state on every backend change
/// (the backend itself is a mutable singleton).
class StoreState {
  const StoreState(this.backend, this.rev);
  final MockBackend backend;
  final int rev;
}

/// Single app-wide store provider. Screens watch [storeProvider] and call
/// methods on `.backend`; every mutation notifies and rev++.
class StoreNotifier extends Notifier<StoreState> {
  @override
  StoreState build() {
    final backend = MockBackend();
    var rev = 0;
    backend.addListener(() {
      rev += 1;
      state = StoreState(backend, rev);
    });
    return StoreState(backend, rev);
  }

  MockBackend get b => state.backend;
}

final storeProvider =
    NotifierProvider<StoreNotifier, StoreState>(StoreNotifier.new);
