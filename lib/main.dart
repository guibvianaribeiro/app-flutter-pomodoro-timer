import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_timer/core/services/notification_service.dart';
import 'package:pomodoro_timer/features/domain/pomodoro_controller.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.init();
    NotificationService.onAction = (action, payload) {
      final ctrl = container.read(pomodoroControllerProvider.notifier);
      switch (action) {
        case 'start_next':
          final next = payload['next'] as String?;
          if (next == 'focus') {
            ctrl.startFocus();
          } else if (next == 'short') {
            ctrl.startShortBreak();
          } else if (next == 'long') {
            ctrl.startLongBreak();
          }
          break;
        case 'add_5':
          ctrl.addMinutesToCurrent(5);
          break;
        case 'pause':
          ctrl.pause();
          break;
      }
    };
  });
}
