import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageClient{

  Future<String> getValueFromSharedPref(String key) async {
    try {
      var pref = await SharedPreferences.getInstance();
      return pref.getString(key) ?? null;
    } catch (error, stackTrace) {
      debugPrint('error in get value from Storage $error , $stackTrace');
      return error;
    }
  }

  Future<void> setValueToSharedPref({String key, String value}) async {
    try {
      var pref = await SharedPreferences.getInstance();
      await pref.setString(key, value);
    } catch (error, stackTrace) {
      debugPrint('error in set value to Storage $error , $stackTrace');
      return error;
    }
  }

  Future<void> clearSharedPref({List<String> keys}) async {
    try {
      var pref = await SharedPreferences.getInstance();
      if(keys!=null && keys.isNotEmpty)
    {
      keys.forEach((key)async {
       await pref.remove(key);
      });
    }
  } catch (error, stackTrace) {
  debugPrint('error in clear value from Storage $error , $stackTrace');
  return error;
  }

  }
}
