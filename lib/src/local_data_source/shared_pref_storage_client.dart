import 'package:flutter/foundation.dart';
// import 'package:hive/hive.dart';
// import 'package:idall_in_app_authentication/src/idall_strs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefStorageClient {
  Future<String> getValueFromSharedPref(String key) async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      return _prefs.getString(key)?? '';
    } catch (error, stackTrace) {
      debugPrint('error in get value from Storage $error , $stackTrace');
      return error;
    }
  }

  Future<void> setValueToSharedPref({String key, String value}) async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setString(key, value);
    } catch (error, stackTrace) {
      debugPrint('error in set value to Storage $error , $stackTrace');
      return error;
    }
  }

  Future<void> clearSharedPref({List<String> keys}) async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      keys.forEach((key) {
        _prefs.remove(key);
      });

    } catch (error, stackTrace) {
      debugPrint('error in clear value from Storage $error , $stackTrace');
      return error;
    }
  }
}
