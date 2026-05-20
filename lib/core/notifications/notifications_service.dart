import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  NotificationsService();

  static const int _budgetAlertId = 1001;
  static const String _channelId = 'budget_limit_alerts';
  static const String _channelName = 'Budget Limit Alerts';

  /// White silhouette on transparent — required for Android status bar (release).
  static const String _androidIcon = 'ic_notification';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _permissionGranted = false;

  bool get isReady => _initialized;
  bool get permissionGranted => _permissionGranted;

  /// Plugin setup + channel creation. Safe to call before [runApp].
  Future<void> initialize() async {
    if (_initialized) return;

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    try {
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings(_androidIcon),
          iOS: iosSettings,
        ),
      );
      await _createAndroidChannel();
      _initialized = true;
      debugPrint('Notifications: initialized (icon=$_androidIcon)');
    } catch (error, stack) {
      debugPrint('Notifications: initialize failed: $error\n$stack');
    }
  }

  /// Request OS permission. Call after the first frame when an Activity exists.
  Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }
    if (!_initialized) return false;

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      try {
        final granted =
            await androidPlugin.requestNotificationsPermission() ?? false;
        _permissionGranted = granted;
        debugPrint('Notifications: Android permission granted=$granted');
      } catch (error, stack) {
        debugPrint(
          'Notifications: Android permission request failed: $error\n$stack',
        );
        try {
          _permissionGranted =
              await androidPlugin.areNotificationsEnabled() ?? false;
        } catch (_) {
          _permissionGranted = false;
        }
      }
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
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
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> _ensureCanNotify() async {
    if (!_initialized) {
      await initialize();
    }
    if (!_initialized) return false;

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      _permissionGranted = enabled ?? false;
      if (!_permissionGranted) {
        debugPrint(
          'Notifications: blocked — OS notifications disabled or not granted',
        );
      }
      return _permissionGranted;
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
    final body =
        'You\'ve spent ₹$spentText this month (limit: ₹$limitText).';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription:
          'Alerts when monthly spending exceeds your budget limit',
      importance: Importance.high,
      priority: Priority.high,
      icon: _androidIcon,
      playSound: true,
      enableVibration: true,
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

    debugPrint(
      'Notifications: show() id=$_budgetAlertId channel=$_channelId '
      'icon=$_androidIcon title="$title"',
    );
    debugPrint(
      'Notifications: show() body="$body" permissionGranted=$_permissionGranted',
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
      debugPrint('Notifications: show() completed');
    } catch (error, stack) {
      debugPrint('Notifications: show() failed: $error\n$stack');
    }
  }
}
