import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionProvider extends ChangeNotifier {
  //Variable
  String _version = "Loading...";

  //Getter
  String get version => _version;

  //Function

  //This function will load version of app to show in about screen
  Future<void> loadVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    notifyListeners();
  }
}
