import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idall_in_app_authentication/idall_in_app_authentication.dart';

void main() {
  const MethodChannel channel = MethodChannel('idall_in_app_authentication');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await IdallInAppAuthentication.platformVersion, '42');
  });
}
