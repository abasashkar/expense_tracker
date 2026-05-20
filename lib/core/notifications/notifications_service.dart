import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  NotificationsService();

  static const int _budgetAlertId = 1001;
  static const String _channelId = 'budget_limit_alerts';
  static const String _channelName = 'Budget Limit Alerts';

  static const String _primaryAndroidIcon = 'ic_notification';
  static const String _fallbackAndroidIcon = 'ic_notification_warning';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _permissionGranted = false;
  String _resolvedAndroidIcon = _primaryAndroidIcon;

  bool get isReady => _initialized;
  bool get permissionGranted => _permissionGranted;

  Future<void> initialize() async {
    if (_initialized) return;

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    for (final icon in [_primaryAndroidIcon, _fallbackAndroidIcon]) {
      try {
        await _plugin.initialize(
          InitializationSettings(
            android: AndroidInitializationSettings(icon),
            iOS: iosSettings,
          ),
        );
        await _createAndroidChannel();
        _resolvedAndroidIcon = icon;
        _initialized = true;
        debugPrint('Notifications: initialized (icon=$icon)');
        return;
      } catch (error, stack) {
        debugPrint('Notifications: init ($icon) failed: $error\n$stack');
      }
    }

    debugPrint('Notifications: failed to initialize plugin');
  }

  Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }
    if (!_initialized) return false;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      try {
        final granted = await androidPlugin.requestNotificationsPermission() ?? false;
        _permissionGranted = granted;
        debugPrint('Notifications: Android permission granted=$granted');
      } catch (error, stack) {
        debugPrint(
          'Notifications: Android permission request failed: $error\n$stack',
        );
        try {
          _permissionGranted = await androidPlugin.areNotificationsEnabled() ?? false;
        } catch (_) {
          _permissionGranted = false;
        }
      }
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      try {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        _permissionGranted = granted ?? _permissionGranted;
      } catch (error, stack) {
        debugPrint('Notifications: iOS permission failed: $error\n$stack');
      }
    }

    return _permissionGranted;
  }

  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Alerts when monthly spending exceeds your budget limit',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> _ensureCanNotify() async {
    if (!_initialized) {
      await initialize();
    }
    if (!_initialized) return false;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      if (enabled != false) {
        _permissionGranted = true;
        return true;
      }
      return requestPermissions();
    }

    return _permissionGranted;
  }

  Future<void> showBudgetLimitExceeded({
    required double monthlySpent,
    required double limit,
  }) async {
    if (!await _ensureCanNotify()) {
      debugPrint('Notifications: cannot show — permission not granted');
      return;
    }

    final spentText = monthlySpent.toStringAsFixed(0);
    final limitText = limit.toStringAsFixed(0);

    const title = 'Monthly budget limit exceeded';
    final body = 'You\'ve spent ₹$spentText this month (limit: ₹$limitText).';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Alerts when monthly spending exceeds your budget limit',
      importance: Importance.max,
      priority: Priority.high,
      icon: _resolvedAndroidIcon,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
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
        body,
        NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
      );
    } catch (error, stack) {
      debugPrint('Notifications: show() failed: $error\n$stack');
    }
  }
}
