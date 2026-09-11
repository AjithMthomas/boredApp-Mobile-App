import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_need/core/theme/app_theme.dart';

import 'app_router.dart';

void main() {
  runApp(const ProviderScope(child: TimeNeedApp()));
}

class TimeNeedApp extends ConsumerWidget {
  const TimeNeedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'TIME~NEED',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
