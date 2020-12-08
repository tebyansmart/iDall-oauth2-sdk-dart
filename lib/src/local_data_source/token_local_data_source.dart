import 'package:flutter/foundation.dart';
import 'token_storage_client.dart';

class TokenLocalDataSource{

  TokenStorageClient _tokenStorageClient;


  TokenLocalDataSource(){
    _tokenStorageClient=TokenStorageClient();
  }


  static const String _ACCESS_TOKEN_KEY = 'access_idall_token_key';
  static const String _ACCESS_TOKEN_EXPIRATION_KEY =
      'expiration_idall_access_token_key';

  static const String _REFRESH_TOKEN_KEY = 'refresh_token_idall';


  
  Future<String> getAccessToken() async {
    var token =
    await _tokenStorageClient.getValueFromSharedPref(_ACCESS_TOKEN_KEY);
    debugPrint('access token is: $token');
    return token;
  }

  
  Future<int> getAccessTokenExpirationDate() async {
    try {
      var stringDate =await _tokenStorageClient.
      getValueFromSharedPref(_ACCESS_TOKEN_EXPIRATION_KEY);
      return int.tryParse(stringDate);
    } catch (error) {
      return 0;
    }
  }

  
  Future<void> setAccessTokenToSharedPref(String accessToke) async {
    debugPrint('saving access token $accessToke');
    await _tokenStorageClient
        .setValueToSharedPref(key: _ACCESS_TOKEN_KEY, value: accessToke);
  }

  
  Future<void> setExpirationDateToSharedPref(String expirationDate) async {
    debugPrint('saving expiration date $expirationDate');
    await _tokenStorageClient.setValueToSharedPref(
        key: _ACCESS_TOKEN_EXPIRATION_KEY, value: expirationDate);
  }

  
  Future<void> setRefreshTokenToSharedPref(String refreshToken) async {
    debugPrint('saving refresh token $refreshToken');
    await _tokenStorageClient.setValueToSharedPref(
        key: _REFRESH_TOKEN_KEY, value: refreshToken);
  }

  
  Future<bool> hasAccessToken() async {
    try {
      var jwt = await getAccessToken();
      return (jwt != null && jwt !='');
    } catch (error, stacktrace) {
      debugPrint('error in check has jwt $error $stacktrace');
      return false;
    }
  }

  
  Future<String> getRefreshToken() async {
    return await _tokenStorageClient
        .getValueFromSharedPref(_REFRESH_TOKEN_KEY);
  }

  
  Future<void> clearTokenSharedPref() async {
    await _tokenStorageClient.clearSharedPref(keys: [_REFRESH_TOKEN_KEY,_ACCESS_TOKEN_EXPIRATION_KEY,_ACCESS_TOKEN_KEY]);
  }

}