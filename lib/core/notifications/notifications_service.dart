import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  NotificationsService();

  static const int _budgetAlertId = 1001;
  static const String _channelId = 'budget_limit_alerts';
  static const String _channelName = 'Budget Limit Alerts';

  /// Small status-bar icon (white silhouette on transparent background).
  static const String _androidIcon = 'ic_notification_warning';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings(_androidIcon);
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Alerts when monthly spending exceeds your budget limit',
      importance: Importance.high,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    _initialized = true;
  }

  Future<void> showBudgetLimitExceeded({
    required double monthlySpent,
    required double limit,
  }) async {
    if (!_initialized) await init();

    final spentText = monthlySpent.toStringAsFixed(0);
    final limitText = limit.toStringAsFixed(0);

    const title = 'Monthly budget limit exceeded';
    final body =
        'You\'ve spent <b>₹$spentText</b> this month (limit: <b>₹$limitText</b>).';
    final plainBody =
        'You\'ve spent ₹$spentText this month (limit: ₹$limitText).';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription:
          'Alerts when monthly spending exceeds your budget limit',
      importance: Importance.high,
      priority: Priority.high,
      icon: _androidIcon,
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: false,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      _budgetAlertId,
      title,
      plainBody,
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }
}
