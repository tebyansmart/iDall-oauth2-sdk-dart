import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:rxdart/rxdart.dart';
import '../local_data_source/token_local_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/idall_response_modes.dart';
import 'model/open_id_config_model.dart';
import 'model/refresh_token.dart';
import 'model/token_data.dart';

class IdallAuthenticator{

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
  static final IdallAuthenticator _instance = IdallAuthenticator._internal();

  factory IdallAuthenticator() => _instance;

  IdallAuthenticator._internal(){
    _userIsAuthenticatedSubject= BehaviorSubject<bool>();
    _userIsAuthenticatedSubject.add(false);
    _tokenLocalDataSource=TokenLocalDataSource();
    _listenForAuthCode();
  }


  Future<IdallResponseModes> setIdallConfig(String clientId,String scopes) async {
    try {
      var result = await _getIdallConfiguration();

      if(result==IdallResponseModes.success) {
        _grant = oauth2.AuthorizationCodeGrant(
            clientId,
            Uri.parse(_idallConfig.authorizationEndpoint),
            Uri.parse(_idallConfig.tokenEndpoint),
            httpClient: http.Client());


        _authorizationUrl = _grant.getAuthorizationUrl(_redirectUrl, scopes: [
          scopes,
        ]);;
        _clientId = clientId;
      }
      return result;
    }
    catch (error, stacktrace) {
      debugPrint('error in get OpenIdConfigs is $error  $stacktrace');
      return IdallResponseModes.unknownError;
    }
  }
  Future<bool> authenticate() async{
    assert(_idallConfig != null);
    debugPrint('idall  token endpoint is $_authorizationUrl');
    return await launch(_authorizationUrl.toString(),);
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
        var uri = Uri.parse(event);
        var code= uri.queryParameters['code'];
        debugPrint('code is $code');
        _getAccessTokenFrom(event);
      }
    });
  }
  Future<void> _getAccessTokenFrom(String codeUrl) async {
    try {
      var uri = Uri.parse(codeUrl);
      var accessTokenClient =
      await _grant.handleAuthorizationResponse(uri.queryParameters);
      debugPrint(
          'response for access token  ${accessTokenClient.credentials.accessToken}');
      var tokenData= TokenData(accessToken: accessTokenClient.credentials.accessToken,
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



  Future<IdallResponseModes> _getIdallConfiguration() async {
    try {
      var fullUrl = Uri.http(_idallDomain, _path, {})
          .toString();
      /// make http call
      final response = await Dio()
          .get(fullUrl,
          options: Options(
            headers: {},
            responseType: ResponseType.json,
            validateStatus: (statusCode) => statusCode < 550,
          ));
      try{
        if(_httpRequestEnumHandler(response.statusCode)==IdallResponseModes.success) {
          _idallConfig= OpenIdConfigModel.fromJson(json.decode(json.encode(response.data)));
        }
        return _httpRequestEnumHandler(response.statusCode);
      }catch(e){
        return IdallResponseModes.failedToParseJson;
      }
    } on TimeoutException
    {
      return IdallResponseModes.requestTimeOut;
    }
    catch (error, stack) {
      debugPrint('error in get  $error,$stack');
      return IdallResponseModes.unknownError;
    }
  }




  Future<IdallResponseModes> refreshTokenIfExpired() async{
    if (await _isTokenExpired()) {
      var refreshTokenResult =
      await doRefreshToken();
      if (refreshTokenResult!=IdallResponseModes.success) {
        return refreshTokenResult;
      }
    }
    return IdallResponseModes.success;
  }
  Future<bool> _isTokenExpired() async {

    if (DateTime.now().millisecondsSinceEpoch >=( (await _tokenLocalDataSource.getAccessTokenExpirationDate()) ?? 0)) {
      debugPrint('token expired and should get new token');
      return true;
    }
    debugPrint('token is not expired');
    return false;
  }
  Future<IdallResponseModes> doRefreshToken() async {
    try {
      var body = _getRefreshTokenBody(await _tokenLocalDataSource.getRefreshToken());
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

      if(_httpRequestEnumHandler(response.statusCode)==IdallResponseModes.success){
        try{
          var refreshToken = RefreshToken.fromJson(response.data);
          await _updateValuesInSharedPref(refreshToken);
        }catch(e){
          return IdallResponseModes.failedToParseJson;
        }
      }
      return _httpRequestEnumHandler(response.statusCode);

    } catch (error, stackTrace) {
      debugPrint('error in refresh token $error $stackTrace');
      return IdallResponseModes.unknownError;
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

  IdallResponseModes _httpRequestEnumHandler(int statusCode){
    switch (statusCode){
      case 200:
        return IdallResponseModes.success;
        break;
    case 201:
    return IdallResponseModes.success;
    break;
    case 204:
    return IdallResponseModes.success;
    break;
    case 500:
    return IdallResponseModes.internalServerError;
    break;
    case 400:
    return IdallResponseModes.badRequest;
    break;
    case 401:
    return IdallResponseModes.unauthorized;
    break;
    case 415:
    return IdallResponseModes.unsupportedMediaType;
    break;
    case 404:
    return IdallResponseModes.notFound;
    break;
    case 405:
    return IdallResponseModes.methodNotAllowed;
    break;
      case 403:
        return IdallResponseModes.forbidden;
        break;
      default:
        return IdallResponseModes.unknownError;
        break;
    }
  }

}