import 'package:flutter/foundation.dart';
import 'shared_pref_storage_client.dart';

class LocalDataSource{

  SharedPrefStorageClient _sharedPrefStorageClient;

  LocalDataSource(){
    _sharedPrefStorageClient=SharedPrefStorageClient();
  }


  static const String _ACCESS_TOKEN_KEY = "access_idall_token_key";
  static const String _ACCESS_TOKEN_EXPIRATION_KEY =
      "expiration_idall_access_token_key";

  static const String _REFRESH_TOKEN_KEY = "refresh_token_idall";
  static const String _SCOPES_KEY='idall_scopes';
  static const String _CLIENT_ID_KEY='idall_client_id';

  static const String _CODE_VERIFIER_KEY= 'idall_code_verifier';
  static const String _STATE_KEY='idall_state';
  
  Future<String> getAccessTokenFromMemory() async {
    String token =
    await _sharedPrefStorageClient.getValueFromSharedPref(_ACCESS_TOKEN_KEY);
    debugPrint('access token is: $token');
    return token;
  }

  Future<String> getScopesFromMemory() async {
    String scopes =
    await _sharedPrefStorageClient.getValueFromSharedPref(_SCOPES_KEY);
    debugPrint('scopes are: $scopes');
    return scopes;
  }

  Future<String> getClientIdFromMemory() async {
    String clientId =
    await _sharedPrefStorageClient.getValueFromSharedPref(_CLIENT_ID_KEY);
    debugPrint('client id is: $clientId');
    return clientId;
  }

  
  Future<int> getAccessTokenExpirationDateFromMemory() async {
    try {
      String stringDate =await _sharedPrefStorageClient.
      getValueFromSharedPref(_ACCESS_TOKEN_EXPIRATION_KEY);
      return int.tryParse(stringDate);
    } catch (error) {
      return 0;
    }
  }

  
  Future<void> setAccessTokenToMemory(String accessToke) async {
    debugPrint('saving access token $accessToke');
    await _sharedPrefStorageClient.setValueToSharedPref(key: _ACCESS_TOKEN_KEY, value: accessToke);
  }

  Future<void> setScopesToMemory(String scopes) async {
    debugPrint('saving scopes $scopes');
    await _sharedPrefStorageClient
        .setValueToSharedPref(key: _SCOPES_KEY, value: scopes);
  }

  Future<void> setClientIdToMemory(String clientId) async {
    debugPrint('saving client Id  $clientId');
    await _sharedPrefStorageClient
        .setValueToSharedPref(key: _CLIENT_ID_KEY, value: clientId);
  }

  
  Future<void> setExpirationDateToMemory(String expirationDate) async {
    debugPrint('saving expiration date $expirationDate');
    await _sharedPrefStorageClient.setValueToSharedPref(
        key: _ACCESS_TOKEN_EXPIRATION_KEY, value: expirationDate);
  }

  
  Future<void> setRefreshTokenToMemory(String refreshToken) async {
    debugPrint('saving refresh token $refreshToken');
    await _sharedPrefStorageClient.setValueToSharedPref(
        key: _REFRESH_TOKEN_KEY, value: refreshToken);
  }

  
  Future<bool> hasAccessToken() async {
    try {
      var jwt = await getAccessTokenFromMemory();
      return (jwt != null && jwt !='');
    } catch (error, stacktrace) {
      debugPrint('error in check has jwt $error $stacktrace');
      return false;
    }
  }

  
  Future<String> getRefreshTokenFromMemory() async {
    return await _sharedPrefStorageClient.getValueFromSharedPref(_REFRESH_TOKEN_KEY);
  }

  
  Future<void> clearIdallMemory() async {
    await _sharedPrefStorageClient.clearSharedPref(keys: [
      _ACCESS_TOKEN_EXPIRATION_KEY,
      _CODE_VERIFIER_KEY,
      _STATE_KEY,
      _SCOPES_KEY,_REFRESH_TOKEN_KEY,
      _ACCESS_TOKEN_KEY,
      _CODE_VERIFIER_KEY,
      _STATE_KEY,]);
  }

  Future<String> getCodeVerifierFromMemory() async{
    return await _sharedPrefStorageClient.getValueFromSharedPref(_CODE_VERIFIER_KEY);
  }

  Future<void> setCodeVerifierToMemory(String codeVerifier) async{
   await _sharedPrefStorageClient.setValueToSharedPref(key: _CODE_VERIFIER_KEY, value: codeVerifier);
 }

  Future<void> setIdallStateToMemory(String state) async{
    debugPrint('saving state $state');
    await _sharedPrefStorageClient.setValueToSharedPref(
        key: _STATE_KEY, value: state);
  }

  Future<String> getIdallStateFromMemory() async{
    return await _sharedPrefStorageClient.getValueFromSharedPref(_STATE_KEY);
  }

}