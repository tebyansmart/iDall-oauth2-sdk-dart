import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageClient{

  final storage = new FlutterSecureStorage();

  Future<String> getValueFromSecureStorage(String key) async {
    try {
      return  await storage.read(key: key);
    } on PlatformException catch (e) {
      debugPrint("Failed to get value from secure storage: '${e.message}'.") ;
      return '';
    }
  }

  Future<void> setValueToSecureStorage({String key, String value}) async {
    try {
      return await storage.write(key: key,value: value);
    } on PlatformException catch (e) {
      debugPrint("Failed to set value from secure storage: '${e.message}'.") ;
    }
  }

  Future<void> clearSecureStorage({List<String> keys}) async {
    try {
      if(keys.isNotEmpty)
        {
          keys.forEach((key) async{
            await storage.delete(key: key);
          });
        }
    } on PlatformException catch (e) {
      debugPrint("Failed to clear secure storage: '${e.message}'.") ;
    }
  }
}
