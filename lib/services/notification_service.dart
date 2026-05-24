import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages local push notifications for the SMS transaction reminder feature.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _baseId = 1001;
  static const String _channelId = 'sms_transaction_reminder';
  static const String _channelName = 'Transaction Detected';
  static const String _channelDesc =
      'Notifies when a bank transaction SMS is detected';

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    // v21 uses named parameters
    await _plugin.initialize(settings: initSettings);
  }

  Future<void> requestPermissions() async {
    var android =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await android?.requestNotificationsPermission();
  }

  /// Show a reminder notification after an SMS transaction is detected.
  Future<void> showTransactionReminder({
    required double amount,
    required String bankName,
    required String paymentMethod,
    required int notificationId,
  }) async {
    var androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'New transaction detected',
      styleInformation: BigTextStyleInformation(
        'A ₹${amount.toStringAsFixed(2)} payment via $paymentMethod ($bankName) was detected.\n'
        'Tap to add a category name like "Food", "Shopping" or "Transport".',
        contentTitle: '💳 Transaction Detected — Add Category',
        summaryText: bankName,
      ),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    var notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    // v21 uses named parameters
    await _plugin.show(
      id: _baseId + notificationId,
      title: '💳 Transaction Detected',
      body:
          '₹${amount.toStringAsFixed(2)} via $paymentMethod — Tap to categorize',
      notificationDetails: notifDetails,
    );
  }
}
