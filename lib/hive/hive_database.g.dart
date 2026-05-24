// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_database.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AmountAdapter extends TypeAdapter<Amount> {
  @override
  final int typeId = 0;

  @override
  Amount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Amount(
      fields[0] as String,
      fields[1] as String,
      fields[2] as double,
      fields[3] as String,
      isIncome: fields[4] as bool?,
      paymentMethod: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Amount obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.subtitle)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.isIncome)
      ..writeByte(5)
      ..write(obj.paymentMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BudgetLimitAdapter extends TypeAdapter<BudgetLimit> {
  @override
  final int typeId = 1;

  @override
  BudgetLimit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetLimit(
      fields[0] as String,
      fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetLimit obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.limitAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetLimitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SavingsGoalAdapter extends TypeAdapter<SavingsGoal> {
  @override
  final int typeId = 2;

  @override
  SavingsGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsGoal(
      fields[0] as String,
      fields[1] as double,
      fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsGoal obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.targetAmount)
      ..writeByte(2)
      ..write(obj.savedAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringExpenseAdapter extends TypeAdapter<RecurringExpense> {
  @override
  final int typeId = 3;

  @override
  RecurringExpense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringExpense(
      fields[0] as String,
      fields[1] as double,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      isIncome: fields[6] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringExpense obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.paymentMethod)
      ..writeByte(4)
      ..write(obj.interval)
      ..writeByte(5)
      ..write(obj.nextDueDate)
      ..writeByte(6)
      ..write(obj.isIncome);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomCategoryAdapter extends TypeAdapter<CustomCategory> {
  @override
  final int typeId = 4;

  @override
  CustomCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomCategory(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomCategory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PendingTransactionAdapter extends TypeAdapter<PendingTransaction> {
  @override
  final int typeId = 5;

  @override
  PendingTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingTransaction(
      amount: fields[0] as double,
      isDebit: fields[1] as bool,
      bankName: fields[2] as String,
      paymentMethod: fields[3] as String,
      merchant: fields[4] as String,
      accountLast4: fields[5] as String,
      rawSms: fields[6] as String,
      detectedAtMs: fields[7] as int,
      category: fields[8] as String,
      notes: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PendingTransaction obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.isDebit)
      ..writeByte(2)
      ..write(obj.bankName)
      ..writeByte(3)
      ..write(obj.paymentMethod)
      ..writeByte(4)
      ..write(obj.merchant)
      ..writeByte(5)
      ..write(obj.accountLast4)
      ..writeByte(6)
      ..write(obj.rawSms)
      ..writeByte(7)
      ..write(obj.detectedAtMs)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
