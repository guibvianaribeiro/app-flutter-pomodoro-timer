import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme_provider.dart';
import 'features/timer/presentation/pages/timer_page.dart';
import 'features/settings/presentation/pages/help_page.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro Timer',
      theme: theme,
      routes: {
        '/': (_) => const TimerPage(),
        '/prefs': (_) => const HelpPage(),
      },
    );
  }
}
