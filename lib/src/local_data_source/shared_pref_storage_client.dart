import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:idall_in_app_authentication/src/idall_strs.dart';

class SharedPrefStorageClient {
  Future<String> getValueFromSharedPref(String key) async {
    try {
      if (!Hive.isBoxOpen(IdallStrs.hiveBox))
        await Hive.openBox(IdallStrs.hiveBox);
      var box = Hive.box(IdallStrs.hiveBox);
      return box.get(key);
    } catch (error, stackTrace) {
      debugPrint('error in get value from Storage $error , $stackTrace');
      return error;
    }
  }

  Future<void> setValueToSharedPref({String key, String value}) async {
    try {
      if (!Hive.isBoxOpen(IdallStrs.hiveBox))
        await Hive.openBox(IdallStrs.hiveBox);
      var box = Hive.box(IdallStrs.hiveBox);
      box.put(key, value);
    } catch (error, stackTrace) {
      debugPrint('error in set value to Storage $error , $stackTrace');
      return error;
    }
  }

  Future<void> clearSharedPref({List<String> keys}) async {
    try {
      var box = Hive.box(IdallStrs.hiveBox);
      box.clear();
    } catch (error, stackTrace) {
      debugPrint('error in clear value from Storage $error , $stackTrace');
      return error;
    }
  }
}
