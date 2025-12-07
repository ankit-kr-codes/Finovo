import 'package:expen/hive/hive_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AmountProvider with ChangeNotifier {
  // Variables
  final Box<Amount> _box = Hive.box<Amount>('expenses');
  double _range = 2000;
  bool _showDateTime = true;

  // Constructor
  AmountProvider() {
    _loadRange();
    _loadDateTime();
  }

  // Getters
  List<Amount> get amounts => _box.values.toList().reversed.toList();
  double get range => _range;
  bool get showDateTime => _showDateTime;
  double get totalAmount =>
      _box.values.fold(0, (sum, item) => sum + (item.amount).toDouble());

  //Functions

  //This Function Show Date and Time
  Future showDateTimeFunction(bool newDateTime) async {
    _showDateTime = newDateTime;

    var pref = await SharedPreferences.getInstance();
    pref.setBool('showDateTime', newDateTime);
    notifyListeners();
  }

  //This Function Loads Date and Time
  Future _loadDateTime() async {
    var pref = await SharedPreferences.getInstance();
    _showDateTime = pref.getBool('showDateTime') ?? true;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  //This function sets a target for spending money
  Future<void> setRange(double newRange) async {
    _range = newRange;

    var prefs = await SharedPreferences.getInstance();
    prefs.setDouble('targetLimit', newRange);
    notifyListeners();
  }

  //This function loads the range when its called
  Future<void> _loadRange() async {
    var prefs = await SharedPreferences.getInstance();
    _range = prefs.getDouble('targetLimit') ?? 2000;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  //This function adds expense to the list(shows in home screen) //NEW - AIDAN H - TAKES NEW DATE INPUT, IF DATE SELECTED IS BEFORE CURRENT DATE THEN DO NOT DISPLAY TIME.
  Future addAmount(String title, String subtitle, double amount, DateTime date) async {
    String formatDateTime(DateTime dateTime) {
      DateTime date1 = DateTime(dateTime.year, dateTime.month, dateTime.day);
      DateTime date2 = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      if(date1.isBefore(date2)){
        return DateFormat('dd MMMM yyyy').format(dateTime);
      }else{
        return DateFormat('dd MMMM yyyy  hh:mm a').format(dateTime);
      }
    }
    
    String dateTime = formatDateTime(date);

    var newAmount = Amount(title, subtitle, amount, dateTime);

    await _box.add(newAmount); // Store in Hive
    notifyListeners();
  }

  //This function delete a specific expense
  void deleteAmount(Amount amount) {
    int correctIndex = _box.values.toList().indexOf(amount);
    if (correctIndex != -1) {
      _box.deleteAt(correctIndex);
      notifyListeners();
    }
  }

  //This function delets all the expenses
  Future deleteAllExpenses() async {
    await _box.clear();
    notifyListeners();
  }
}
