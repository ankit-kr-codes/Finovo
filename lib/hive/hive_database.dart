import 'package:hive_flutter/hive_flutter.dart';
part 'hive_database.g.dart';

//For Local Storage (Transactions)
@HiveType(typeId: 0)
class Amount extends HiveObject {
  @HiveField(0)
  final String title; // Represents Category name

  @HiveField(1)
  final String subtitle; // Represents Notes

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String dateTime;

  @HiveField(4)
  final bool? isIncome;

  @HiveField(5)
  final String? paymentMethod;

  Amount(this.title, this.subtitle, this.amount, this.dateTime, {this.isIncome = false, this.paymentMethod = "Cash"});

  bool get incomeStatus => isIncome ?? false;
  String get payMethod => paymentMethod ?? "Cash";
}

// Budget limit per category
@HiveType(typeId: 1)
class BudgetLimit extends HiveObject {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final double limitAmount;

  BudgetLimit(this.category, this.limitAmount);
}

// Savings Goal
@HiveType(typeId: 2)
class SavingsGoal extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final double targetAmount;

  @HiveField(2)
  final double savedAmount;

  SavingsGoal(this.title, this.targetAmount, this.savedAmount);
}

// Recurring Expense
@HiveType(typeId: 3)
class RecurringExpense extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String paymentMethod;

  @HiveField(4)
  final String interval; // "Weekly", "Monthly", "Yearly"

  @HiveField(5)
  final String nextDueDate; // Format: "yyyy-MM-dd"

  @HiveField(6)
  final bool? isIncome;

  RecurringExpense(
    this.title,
    this.amount,
    this.category,
    this.paymentMethod,
    this.interval,
    this.nextDueDate, {
    this.isIncome = false,
  });

  bool get incomeStatus => isIncome ?? false;
}

// Custom Category
@HiveType(typeId: 4)
class CustomCategory extends HiveObject {
  @HiveField(0)
  final String name;

  CustomCategory(this.name);
}

// SMS-detected pending transaction (awaiting user categorization)
@HiveType(typeId: 5)
class PendingTransaction extends HiveObject {
  @HiveField(0)
  final double amount;

  @HiveField(1)
  final bool isDebit;

  @HiveField(2)
  final String bankName;

  @HiveField(3)
  final String paymentMethod;

  @HiveField(4)
  final String merchant;

  @HiveField(5)
  final String accountLast4;

  @HiveField(6)
  final String rawSms;

  @HiveField(7)
  final int detectedAtMs; // milliseconds since epoch

  @HiveField(8)
  final String category; // user-assigned category (empty until reviewed)

  @HiveField(9)
  final String notes; // user-assigned notes

  PendingTransaction({
    required this.amount,
    required this.isDebit,
    required this.bankName,
    required this.paymentMethod,
    required this.merchant,
    required this.accountLast4,
    required this.rawSms,
    required this.detectedAtMs,
    required this.category,
    required this.notes,
  });
}
