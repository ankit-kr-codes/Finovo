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
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Amount(
      fields[0] as String? ?? '',
      fields[1] as String? ?? '',
      fields[2] as double? ?? 0.0,
      fields[3] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Amount obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.subtitle)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.dateTime);
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
