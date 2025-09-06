import 'package:flutter/material.dart';
import 'package:pomodoro_timer/core/theme/app_theme.dart';
import 'features/timer/presentation/pages/timer_page.dart';
import 'features/settings/presentation/pages/help_page.dart';
import 'core/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(seedColorProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro Timer',
      theme: AppTheme.lightWithSeed(seed),
      routes: {'/help': (_) => const HelpPage()},
      home: const TimerPage(),
    );
  }
}
