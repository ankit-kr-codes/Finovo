import 'package:hive_flutter/hive_flutter.dart';
part 'hive_database.g.dart';

//For Local Storage
@HiveType(typeId: 0)
class Amount extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String subtitle;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String dateTime;

  Amount(this.title, this.subtitle, this.amount, this.dateTime);
}
