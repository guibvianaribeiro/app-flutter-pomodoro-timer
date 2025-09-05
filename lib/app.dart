import 'package:flutter/material.dart';
import 'package:pomodoro_timer/core/theme/app_theme.dart';
import 'package:pomodoro_timer/features/timer/presentation/pages/timer_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: AppTheme.light,
      home: const TimerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
