import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:rxdart/rxdart.dart';
import '../local_data_source/token_local_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'open_id_config_model.dart';
import 'refresh_token.dart';
import 'token_data.dart';

class IdallAuthenticatorHelper{

  OpenIdConfigModel _idallConfig;
  oauth2.AuthorizationCodeGrant _grant;
  Uri _authorizationUrl;
  BehaviorSubject<bool> _userIsAuthenticatedSubject;
  TokenLocalDataSource _tokenLocalDataSource;
  ///a stream that shows user is authenticated
  Stream<bool> get userIsAuthenticated=> _userIsAuthenticatedSubject;

   final Uri _redirectUrl =  Uri.parse('idall://idall-flutter-auth');
  static const String _idallDomain='accounts.idall.pro';
  static const String _path= '/.well-known/openid-configuration';
  String _clientId;

  ///make class singleton
  static final IdallAuthenticatorHelper _instance = IdallAuthenticatorHelper._internal();

  factory IdallAuthenticatorHelper() => _instance;

  IdallAuthenticatorHelper._internal(){
    _userIsAuthenticatedSubject= BehaviorSubject<bool>();
    _userIsAuthenticatedSubject.add(false);
    _tokenLocalDataSource=TokenLocalDataSource();
    _listenForAuthCode();
  }

  Future<String> getAccessToken() async {
    return _tokenLocalDataSource.getAccessToken();
  }

  Future<int> getAccessTokenExpirationDate() async {
      return _tokenLocalDataSource.getAccessTokenExpirationDate();
  }

  Future<String> getRefreshToken() async {
    return await _tokenLocalDataSource.getRefreshToken();
  }

  Future<bool> hasAccessToken() async {
    return _tokenLocalDataSource.hasAccessToken();
  }

  void _listenForAuthCode(){
    getLinksStream().listen((event) {
      debugPrint('listened value for link is $event');
      if (event.contains('code')) {
        Uri uri = Uri.parse(event);
        String code= uri.queryParameters['code'];
        debugPrint('code is $code');
        _getAccessTokenFrom(event);
      }
    });
  }
  Future<void> _getAccessTokenFrom(String codeUrl) async {
    try {
      Uri uri = Uri.parse(codeUrl);
      oauth2.Client accessTokenClient =
      await _grant.handleAuthorizationResponse(uri.queryParameters);
      debugPrint(
          'response for access token  ${accessTokenClient.credentials.accessToken}');
      TokenData tokenData= TokenData(accessToken: accessTokenClient.credentials.accessToken,
          expirationDate: accessTokenClient.credentials.expiration.millisecondsSinceEpoch,
          refreshToken: accessTokenClient.credentials.refreshToken);

      await _saveAccessToken(tokenData.accessToken);

      await _saveExpirationDate(
          tokenData.expirationDate);

      await _saveRefreshToken(tokenData.refreshToken);
      _userIsAuthenticatedSubject.add(true);

    } catch (error, stackTrace) {
      debugPrint('error in get access token error is $error  $stackTrace');
      _userIsAuthenticatedSubject.add(false);
      throw Exception();
    }
  }
  ///this method save access token in secure storage
  Future<void> _saveAccessToken(String accessToken) async => await _tokenLocalDataSource.setAccessTokenToSharedPref(accessToken);
  ///this method saves expiration token in secure storage
  Future<void> _saveExpirationDate(int expirationDate) async => await _tokenLocalDataSource.setExpirationDateToSharedPref(expirationDate.toString());
  ///this method save refresh token in secure storage
  Future<void> _saveRefreshToken(String refreshToken) async => await _tokenLocalDataSource.setRefreshTokenToSharedPref(refreshToken);


  Future<bool> setIdallConfig(String clientId,String scopes) async {
    try {
      var result = await _getIdallConfiguration();

        this._idallConfig=result;
        _grant = oauth2.AuthorizationCodeGrant(
            clientId,
            Uri.parse(_idallConfig.authorizationEndpoint),
            Uri.parse(_idallConfig.tokenEndpoint),
            httpClient: http.Client());

        Uri authorizationUrl = _grant.getAuthorizationUrl(_redirectUrl, scopes: [
          scopes,
        ]);
        this._authorizationUrl = authorizationUrl;
      _clientId=clientId;
        return true;
      }
      catch (error, stacktrace) {
      debugPrint('error in get OpenIdConfigs is $error  $stacktrace');
      return false;
    }
  }
  Future<OpenIdConfigModel> _getIdallConfiguration() async {
    try {
      String fullUrl = Uri.http(_idallDomain, _path, {})
          .toString();


      /// make http call
      final response = await Dio()
          .get(fullUrl,
          options: Options(
            headers: {},
            responseType: ResponseType.json,
            validateStatus: (statusCode) => statusCode < 550,
          ));

      if(response.statusCode!=200)
        throw Exception();

      OpenIdConfigModel result= OpenIdConfigModel.fromJson(json.decode(json.encode(response.data)));
      return result;

    } catch (error, stack) {
      debugPrint("error in get  $error,$stack");
      throw Exception();
    }
  }


  Future<bool> authenticate() async{
    assert(_idallConfig != null);
   return await launch(_authorizationUrl.toString(),);
  }


  Future<bool> refreshTokenIfExpired() async{
    if (await _isTokenExpired()) {
      bool refreshTokenResult =
      await doRefreshToken();
      if (!refreshTokenResult) {
        return false;
      }
    }
    return true;
  }
  Future<bool> _isTokenExpired() async {

    if (DateTime.now().millisecondsSinceEpoch >=( (await _tokenLocalDataSource.getAccessTokenExpirationDate()) ?? 0)) {
      debugPrint('token expired and should get new token');
      return true;
    }
    debugPrint('token is not expired');
    return false;
  }
  Future<bool> doRefreshToken() async {
    try {
      Map<String, dynamic> body = _getRefreshTokenBody(await _tokenLocalDataSource.getRefreshToken());
      debugPrint(
          'body for refresh token is ${_idallConfig.tokenEndpoint} $body');

      var response = await Dio().post(
          _idallConfig.tokenEndpoint,
          data: body,
          options: Options(
            headers: {},
            contentType: Headers.formUrlEncodedContentType,
            responseType: ResponseType.json,
            validateStatus: (statusCode) => statusCode < 550,));

      debugPrint(
          'refresh token result ${response.statusCode}  ${response.data}');

      if (response.statusCode==200) {
        RefreshToken refreshToken = RefreshToken.fromJson(response.data);
        await _updateValuesInSharedPref(refreshToken);
        return true;
      }

      else {
        return false;
      }
    } catch (error, stackTrace) {
      debugPrint('error in refresh token $error $stackTrace');
      return false;
    }
  }
  Map<String, dynamic> _getRefreshTokenBody(String refreshToken) {
    return {
      'grant_type': 'refresh_token',
      'client_id': _clientId,
      'refresh_token': refreshToken,
    };
  }
  Future<void> _updateValuesInSharedPref(RefreshToken refreshToken) async {
    await _tokenLocalDataSource.clearTokenSharedPref();

    await _tokenLocalDataSource
        .setAccessTokenToSharedPref(refreshToken.accessToken);
    await _tokenLocalDataSource.setExpirationDateToSharedPref(
        (((refreshToken.expiresIn * 1000) +
            DateTime.now().millisecondsSinceEpoch))
            .toString());
    await _tokenLocalDataSource
        .setRefreshTokenToSharedPref(refreshToken.refreshToken);
  }

  Future<void> reset() async {
    debugPrint('resetting idall authenticator');
     _idallConfig=null;
     _grant=null;
     _authorizationUrl=null;
    _clientId=null;
    _userIsAuthenticatedSubject.add(false);
    debugPrint('clearing secure storage');
    await _tokenLocalDataSource.clearTokenSharedPref();
  }


}