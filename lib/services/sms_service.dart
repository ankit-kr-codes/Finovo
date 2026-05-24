import 'dart:async';
import 'package:expen/hive/hive_database.dart';
import 'package:expen/services/notification_service.dart';
import 'package:expen/services/sms_parser.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages reading bank SMS messages from the device inbox and auto-detecting
/// pending transactions for the user to review and categorize.
class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  static const String _lastProcessedKey = 'sms_last_processed_ts';
  static const String _enabledKey = 'sms_auto_detect_enabled';
  static const String _pendingBoxName = 'sms_pending';

  final SmsQuery _query = SmsQuery();
  final NotificationService _notifService = NotificationService();

  // Stream for real-time UI updates when new pending transactions appear
  final StreamController<List<PendingTransaction>> _pendingController =
      StreamController<List<PendingTransaction>>.broadcast();

  Stream<List<PendingTransaction>> get pendingStream =>
      _pendingController.stream;

  Box<PendingTransaction>? _pendingBox;

  Future<void> init() async {
    await _notifService.init();
    _pendingBox = await Hive.openBox<PendingTransaction>(_pendingBoxName);
  }

  /// Returns whether the SMS auto-detect feature is enabled.
  Future<bool> isEnabled() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Enables or disables the SMS auto-detect feature.
  Future<void> setEnabled(bool enabled) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  /// Gets all pending transactions awaiting categorization.
  List<PendingTransaction> getPendingTransactions() {
    return _pendingBox?.values.toList() ?? [];
  }

  /// Requests SMS read permission from the user.
  Future<bool> requestSmsPermission() async {
    var status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Checks if SMS permission is already granted.
  Future<bool> hasSmsPermission() async {
    return await Permission.sms.isGranted;
  }

  /// Scans the SMS inbox for new bank transaction messages since last check.
  /// Returns the count of newly detected transactions.
  Future<int> scanInbox() async {
    if (!await hasSmsPermission()) return 0;

    var enabled = await isEnabled();
    if (!enabled) return 0;

    var prefs = await SharedPreferences.getInstance();
    var lastTs = prefs.getInt(_lastProcessedKey) ?? 0;
    var now = DateTime.now().millisecondsSinceEpoch;

    // Query messages from inbox
    var messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 100,
    );

    // Filter by: newer than last check, from trusted senders, looks like transaction
    var newMessages =
        messages.where((msg) {
          var msgTs =
              msg.dateSent?.millisecondsSinceEpoch ??
              msg.date?.millisecondsSinceEpoch ??
              0;
          if (msgTs <= lastTs) return false;
          var sender = msg.sender ?? '';
          var body = msg.body ?? '';
          return SmsParser.isTrustedBankSender(sender) &&
              SmsParser.looksLikeTransaction(body);
        }).toList();

    int addedCount = 0;
    for (var msg in newMessages) {
      var sender = msg.sender ?? '';
      var body = msg.body ?? '';
      var parsed = SmsParser.parse(sender, body);
      if (parsed == null) continue;

      // De-duplicate: skip if we already have a pending with same amount+bank+ts
      var msgTs =
          msg.dateSent?.millisecondsSinceEpoch ??
          msg.date?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch;
      var isDuplicate = (_pendingBox?.values ?? []).any(
        (p) =>
            p.amount == parsed.amount &&
            p.bankName == parsed.bankName &&
            (p.detectedAtMs - msgTs).abs() < 60000,
      ); // within 1 minute
      if (isDuplicate) continue;

      var pending = PendingTransaction(
        amount: parsed.amount,
        isDebit: parsed.isDebit,
        bankName: parsed.bankName,
        paymentMethod: parsed.paymentMethod,
        merchant: parsed.merchant ?? '',
        accountLast4: parsed.accountLast4 ?? '',
        rawSms: parsed.rawSms,
        detectedAtMs: msgTs,
        category: '',
        notes: parsed.merchant ?? '',
      );

      await _pendingBox?.add(pending);
      addedCount++;

      // Show notification reminder after 3 minutes
      Timer(const Duration(minutes: 3), () {
        _notifService.showTransactionReminder(
          amount: parsed.amount,
          bankName: parsed.bankName,
          paymentMethod: parsed.paymentMethod,
          notificationId: msgTs % 10000,
        );
      });
    }

    // Update last processed timestamp
    await prefs.setInt(_lastProcessedKey, now);

    if (addedCount > 0) {
      _pendingController.add(getPendingTransactions());
    }

    return addedCount;
  }

  /// Approves a pending transaction — saves it to the main Hive expense box.
  Future<void> approvePending(
    PendingTransaction pending,
    String category,
    String notes,
    Box<Amount> expenseBox,
  ) async {
    var dt = DateTime.fromMillisecondsSinceEpoch(pending.detectedAtMs);
    String dateTimeStr;
    var today = DateTime.now();
    var dateOnly = DateTime(dt.year, dt.month, dt.day);
    var todayOnly = DateTime(today.year, today.month, today.day);
    if (dateOnly.isBefore(todayOnly)) {
      dateTimeStr = DateFormat('dd MMMM yyyy').format(dt);
    } else {
      dateTimeStr = DateFormat('dd MMMM yyyy  hh:mm a').format(dt);
    }

    var amount = Amount(
      category.isEmpty ? 'Uncategorized' : category,
      notes.isEmpty ? '[SMS] ${pending.bankName}' : notes,
      pending.amount,
      dateTimeStr,
      isIncome: !pending.isDebit,
      paymentMethod: pending.paymentMethod,
    );
    await expenseBox.add(amount);

    // Remove from pending
    var index = _pendingBox?.values.toList().indexOf(pending) ?? -1;
    if (index != -1) await _pendingBox?.deleteAt(index);
    _pendingController.add(getPendingTransactions());
  }

  /// Dismisses (ignores) a pending transaction without saving.
  Future<void> dismissPending(PendingTransaction pending) async {
    var index = _pendingBox?.values.toList().indexOf(pending) ?? -1;
    if (index != -1) await _pendingBox?.deleteAt(index);
    _pendingController.add(getPendingTransactions());
  }

  /// Dismisses all pending transactions.
  Future<void> dismissAll() async {
    await _pendingBox?.clear();
    _pendingController.add([]);
  }

  void dispose() {
    _pendingController.close();
  }
}
