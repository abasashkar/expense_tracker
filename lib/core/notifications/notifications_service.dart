import 'package:flutter/foundation.dart';
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

    try {
      await _initializePlugin(iconName: _androidIcon);
      await _setupChannelsAndPermissions();
      _initialized = true;
    } catch (error, stack) {
      debugPrint('Notifications init (custom icon) failed: $error\n$stack');
    }

    if (_initialized) return;

    try {
      await _initializePlugin(iconName: '@mipmap/ic_launcher');
      await _setupChannelsAndPermissions();
      _initialized = true;
    } catch (error, stack) {
      debugPrint('Notifications init (default icon) failed: $error\n$stack');
    }
  }

  Future<void> _initializePlugin({required String iconName}) async {
    final androidSettings = AndroidInitializationSettings(iconName);
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  Future<void> _setupChannelsAndPermissions() async {
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

    try {
      await androidPlugin?.requestNotificationsPermission();
    } catch (error, stack) {
      debugPrint('Notification permission request failed: $error\n$stack');
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    try {
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (error, stack) {
      debugPrint('iOS notification permission request failed: $error\n$stack');
    }
  }

  Future<void> showBudgetLimitExceeded({
    required double monthlySpent,
    required double limit,
  }) async {
    if (!_initialized) {
      try {
        await init();
      } catch (_) {
        return;
      }
    }
    if (!_initialized) return;

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

    try {
      await _plugin.show(
        _budgetAlertId,
        title,
        plainBody,
        NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
      );
    } catch (error, stack) {
      debugPrint('Failed to show budget notification: $error\n$stack');
    }
  }
}
