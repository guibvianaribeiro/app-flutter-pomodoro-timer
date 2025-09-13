import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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

  static Future<void> init() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);
    try {
      await _plugin.initialize(settings);
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

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  static Future<void> showCycleFinished({
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    final android = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails();
    final n = NotificationDetails(android: android, iOS: ios);
    await _plugin.show(1001, title, body, n);
  }
}
