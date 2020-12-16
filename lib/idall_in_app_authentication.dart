
// import 'dart:async';
//
// import 'package:flutter/services.dart';

// class IdallInAppAuthentication {
//   static const MethodChannel _channel =
//       const MethodChannel('idall_in_app_authentication');
//
//   static Future<String> get platformVersion async {
//     final String version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }
// }



export 'package:idall_in_app_authentication/src/authenticator/idall_authenticator.dart';
export 'package:idall_in_app_authentication/src/authenticator/model/idall_response_modes.dart';