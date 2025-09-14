import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'pomodoro_timer_channel',
    'Pomodoro Timer',
    description: 'Alertas de ciclos concluídos',
    importance: Importance.high,
  );

  static bool _initialized = false;
  static void Function(String action, Map<String, dynamic> payload)? onAction;

  static Future<void> init() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          'pomodoro_actions',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('start_next', 'Iniciar próxima',
                options: const {DarwinNotificationActionOption.foreground}),
            DarwinNotificationAction.plain('add_5', 'Adicionar 5 min',
                options: {DarwinNotificationActionOption.foreground}),
            DarwinNotificationAction.plain('pause', 'Pausar',
                options: {DarwinNotificationActionOption.foreground}),
          ],
          options: {DarwinNotificationCategoryOption.hiddenPreviewShowTitle},
        ),
      ],
    );
    final settings = InitializationSettings(android: androidInit, iOS: iosInit);
    try {
      await _plugin.initialize(settings,
          onDidReceiveNotificationResponse: (resp) {
        final actionId = resp.actionId ?? '';
        final p = resp.payload;
        Map<String, dynamic> data = {};
        if (p != null && p.isNotEmpty) {
          try {
            data = json.decode(p) as Map<String, dynamic>;
          } catch (_) {}
        }
        onAction?.call(actionId, data);
      });
      _initialized = true;
    } on MissingPluginException {
      // Em alguns cenários de hot reload, o plugin ainda não está registrado.
      // Agenda nova tentativa após o primeiro frame.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _plugin.initialize(settings);
          _initialized = true;
        } catch (_) {}
      });
      return;
    }

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  static Future<void> showCycleFinished({
    required String title,
    required String body,
    required String nextPhase, // 'focus' | 'short' | 'long'
  }) async {
    if (!_initialized) return;
    final payload = json.encode({'next': nextPhase});
    final android = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction('start_next', 'Iniciar próxima'),
        AndroidNotificationAction('add_5', 'Adicionar 5 min'),
        AndroidNotificationAction('pause', 'Pausar'),
      ],
    );
    const ios = DarwinNotificationDetails(
      categoryIdentifier: 'pomodoro_actions',
      presentSound: true,
    );
    final n = NotificationDetails(android: android, iOS: ios);
    await _plugin.show(1001, title, body, n, payload: payload);
  }
}
