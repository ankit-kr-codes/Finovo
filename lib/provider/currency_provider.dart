import 'package:flutter/material.dart';
import 'package:expen/core/currency_symbol.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  //Variables
  int _selectedCurrencyIndex = 0;

  //Getter
  int get selectedCurrencyIndex => _selectedCurrencyIndex;

  String get selectedCurrencySymbol =>
      currencySymbol[_selectedCurrencyIndex]["symbol"] as String;

  //Constructor
  CurrencyProvider() {
    _loadCurrencySymbol();
  }

  //This Function helps user to select currency
  Future<void> selectCurrency(int index) async {
    _selectedCurrencyIndex = index;
    notifyListeners();

    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currencyIndex', index);
  }

  //This Function loads currency when its called
  Future<void> _loadCurrencySymbol() async {
    var prefs = await SharedPreferences.getInstance();
    _selectedCurrencyIndex = prefs.getInt('currencyIndex') ?? 0;

    notifyListeners();
  }
}
