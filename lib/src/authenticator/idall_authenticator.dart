import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
import 'package:flutter/services.dart';

class IdallInAppAuthentication{

  static const platform = const MethodChannel("samples.flutter.io/auth");

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

  static const String _charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';


  ///make class singleton
  static final IdallInAppAuthentication _instance = IdallInAppAuthentication._internal();

  factory IdallInAppAuthentication() => _instance;

  IdallInAppAuthentication._internal(){
    _userIsAuthenticatedSubject= BehaviorSubject<bool>();
    _userIsAuthenticatedSubject.add(false);
    _tokenLocalDataSource=TokenLocalDataSource();
  }


  Future<IdallResponseModes> setIdallConfig(String clientId,String scopes) async {
    try {
      IdallResponseModes result = await _getIdallConfiguration();
      if(result==IdallResponseModes.success) {
        _grant = oauth2.AuthorizationCodeGrant(
            clientId,
            Uri.parse(_idallConfig.authorizationEndpoint),
            Uri.parse(_idallConfig.tokenEndpoint),
            httpClient: http.Client(),
            codeVerifier: await generateCodeVerifier(),
        );

        _authorizationUrl =
        _grant.getAuthorizationUrl(_redirectUrl, scopes: [
          scopes,
        ],
          state: await _generateState(),
        );
        _clientId = clientId;
      }
      ///save to shared pref
      await _saveClientId(clientId);
      await _saveScopes(scopes);
      print('set idall config success');
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
    return await launch(_authorizationUrl.toString(),forceWebView: false,enableJavaScript: false,enableDomStorage: false,);
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

  Future<String> getClientId() async {
    return await _tokenLocalDataSource.getClientId();
  }

  Future<String> getScopes() async {
    return await _tokenLocalDataSource.getScopes();
  }

  Future<String> getCodeVerifier() async {
    return await _tokenLocalDataSource.getCodeVerifier();
  }

  Future<String> _getState() async{
    return await _tokenLocalDataSource.getIdallState();
  }


  Future<bool> hasAccessToken() async {
    return _tokenLocalDataSource.hasAccessToken();
  }

  void listenForAuthCode() async{
    if(Platform.isAndroid) platform.setMethodCallHandler( (MethodCall methodCall) async {
      if(methodCall.method=='idallUrl') {
        String event=methodCall.arguments;
          debugPrint('listened value for link is $event');
          if (event.contains('code')) {
            Uri uri = Uri.parse(event);
            String code = uri.queryParameters['code'];
            debugPrint('code is $code');
            print('client id is : $_clientId');
            String state = uri.queryParameters['state'];
            if(state!= (await _getState())) {
              throw(Exception('state in login is not verified'));
            }
           await _getAccessTokenFrom(event);
          }
        }
      return Future((){});
      });
    if(Platform.isIOS)getLinksStream().listen((event) {
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
  Future<void> _saveAccessToken(String accessToken) async => await _tokenLocalDataSource.setAccessTokenToSecureStorage(accessToken);
  ///this method saves expiration token in secure storage
  Future<void> _saveExpirationDate(int expirationDate) async => await _tokenLocalDataSource.setExpirationDateToSharedPref(expirationDate.toString());
  ///this method save refresh token in secure storage
  Future<void> _saveRefreshToken(String refreshToken) async => await _tokenLocalDataSource.setRefreshTokenToSecureStorage(refreshToken);

  Future<void> _saveClientId(String clientId) async => await _tokenLocalDataSource.setClientIdToSharedPref(clientId);
  Future<void> _saveScopes(String scopes) async => await _tokenLocalDataSource.setScopesToSharedPref(scopes);
  Future<void> _saveCodeVerifier(String codeVerifier) async => await _tokenLocalDataSource.setCodeVerifierToSecureStorage(codeVerifier);
  Future<void> _saveState(String state) async=> await _tokenLocalDataSource.setIdallStateToSecureStorage(state);

  Future<IdallResponseModes> _getIdallConfiguration() async {
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
      try{
        if(_httpRequestEnumHandler(response.statusCode)==IdallResponseModes.success)
        this._idallConfig= OpenIdConfigModel.fromJson(json.decode(json.encode(response.data)));
        return _httpRequestEnumHandler(response.statusCode);
      }catch(e){
        return IdallResponseModes.failedToParseJson;
      }
    } on TimeoutException
    {
      return IdallResponseModes.requestTimeOut;
    }
    catch (error, stack) {
      debugPrint("error in get  $error,$stack");
      return IdallResponseModes.unknownError;
    }
  }

  Future<IdallResponseModes> refreshTokenIfExpired() async{
    if (await _isTokenExpired()) {
      IdallResponseModes refreshTokenResult =
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

      if(_httpRequestEnumHandler(response.statusCode)==IdallResponseModes.success){
        try{
          RefreshToken refreshToken = RefreshToken.fromJson(response.data);
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

    await _tokenLocalDataSource
        .setAccessTokenToSecureStorage(refreshToken.accessToken);
    await _tokenLocalDataSource.setExpirationDateToSharedPref(
        (((refreshToken.expiresIn * 1000) +
            DateTime.now().millisecondsSinceEpoch))
            .toString());
    await _tokenLocalDataSource
        .setRefreshTokenToSecureStorage(refreshToken.refreshToken);
  }

  Future<void> reset() async {
    debugPrint('resetting idall authenticator');
     _idallConfig=null;
     _grant=null;
     _authorizationUrl=null;
    _clientId=null;
    _userIsAuthenticatedSubject.add(false);
    debugPrint('clearing secure storage');
    await _tokenLocalDataSource.clearIdallSharedPref();
    await _tokenLocalDataSource.clearTokenSecureStorage();
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

  Future<String> generateCodeVerifier() async{
    String codeVerifier= await getCodeVerifier();
    if(codeVerifier==null || codeVerifier.isEmpty) {
      codeVerifier = List.generate(
          128, (i) => _charset[Random.secure().nextInt(_charset.length)]).join();
      await _saveCodeVerifier(codeVerifier);
    }
    return codeVerifier;
  }

  Future<String> _generateState() async{
    String state= await _getState();
    if(state==null ) {
      state = List.generate(
          16, (i) => _charset[Random.secure().nextInt(_charset.length)]).join();
      await _saveState(state);
    }
    return state;
  }

}