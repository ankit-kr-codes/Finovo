import 'package:hive_flutter/hive_flutter.dart';

//This Function keeps a backup of user expenses data and then reset/update the app
Future<void> backupAndResetHive() async {
  var oldBox = await Hive.openBox('expenses');
  List<Map<String, dynamic>> backupData = [];

  for (var key in oldBox.keys) {
    backupData.add({'key': key, 'value': oldBox.get(key)});
  }

  await Hive.deleteBoxFromDisk('expenses');
  var newBox = await Hive.openBox('expenses');

  for (var item in backupData) {
    newBox.put(item['key'], item['value']);
  }
}
