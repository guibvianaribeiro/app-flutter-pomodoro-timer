import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_timer/core/theme/theme_provider.dart';
import 'package:pomodoro_timer/features/timer/presentation/pages/timer_page.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: theme,
      home: const TimerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
