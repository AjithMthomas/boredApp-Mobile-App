import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:needy/core/theme/app_theme.dart';

import 'app_router.dart';

void main() {
  runApp(const ProviderScope(child: NeedyApp()));
}

class NeedyApp extends ConsumerWidget {
  const NeedyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'needy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
