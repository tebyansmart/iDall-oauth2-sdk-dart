import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../strs.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefStorageClient {
  Future<String> getValueFromSharedPref(String key) async {
    try {
      if(!Hive.isBoxOpen(Strs.hiveBox))
      await  Hive.openBox(Strs.hiveBox);
      var box = Hive.box(Strs.hiveBox);
      return box.get(key);
      // SharedPreferences pref = await SharedPreferences.getInstance();
      // return pref.getString(key) ?? null;
    } catch (error, stackTrace) {
      debugPrint('error in get value from Storage $error , $stackTrace');
      return error;
    }
  }



  Future<void> setValueToSharedPref({String key, String value}) async {
    try {
      if(!Hive.isBoxOpen(Strs.hiveBox))
       await Hive.openBox(Strs.hiveBox);
      var box = Hive.box(Strs.hiveBox);
      box.put(key, value);

      // SharedPreferences pref = await SharedPreferences.getInstance();
      // await pref.setString(key, value);
    } catch (error, stackTrace) {
      debugPrint('error in set value to Storage $error , $stackTrace');
      return error;
    }
  }

  // Future<void> setListValueToSharedPref({String key, List<String> value}) async {
  //   try {
  //     SharedPreferences pref = await SharedPreferences.getInstance();
  //     await pref.setStringList(key, value);
  //   } catch (error, stackTrace) {
  //     debugPrint('error in set value to Storage $error , $stackTrace');
  //     return error;
  //   }
  // }

  Future<void> clearSharedPref({List<String> keys}) async {
    try {
      var box = Hive.box(Strs.hiveBox);
      box.clear();
      // SharedPreferences pref = await SharedPreferences.getInstance();
      // if (keys != null && keys.isNotEmpty) {
      //   keys.forEach((key) async {
      //     await pref.remove(key);
      //   });
      // }
    } catch (error, stackTrace) {
      debugPrint('error in clear value from Storage $error , $stackTrace');
      return error;
    }
  }
}
