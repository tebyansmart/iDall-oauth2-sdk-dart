# Idall Authenticator

A Flutter plugin for authenticating with Idall. This plugin uses [OAuth2 package](https://pub.dev/packages/oauth2) which is
 a client library for authenticating with a remote service via
  OAuth2 on behalf of a user, and making authorized
   HTTP requests with the user's OAuth2 credentials.
For deep linking it uses [uni_links package](https://pub.dev/packages/uni_links) which is a Flutter plugin 
 to help with App/Deep Links (Android) and Universal 
 Links and Custom URL schemes (iOS).

## Installation 

To use the plugin, add idall_authenticator as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

#### Permission 
Android and iOS require to declare links' permission in a configuration file.

#### For Android
You need to declare this
filter in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <!-- ... other tags -->
  <application ...>
    <activity ...>
      <!-- ... other tags -->

      <!-- Deep Links -->
      <intent-filter android:label="[YOUR_APPLICATION_NAME]">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
          android:scheme="idall-flutter-auth"
          android:host="idall" />
      </intent-filter>

    </activity>
  </application>
</manifest>
```

#### For iOS

 you need to declare this in
`ios/Runner/Info.plist` (or through Xcode's Target Info editor,
under URL Types):

```xml
<?xml ...>
<!-- ... other tags -->
<plist>
<dict>
  <!-- ... other tags -->
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLName</key>
      <string>idall</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>idall-flutter-auth</string>
      </array>
    </dict>
  </array>
  <!-- ... other tags -->
</dict>
</plist>
```

This allows for your app to be started from `idall-flutter-auth://ANYTHING` links.


## Usage

####initializing

to set IdallAuthenticator use: `setIdallConfig`

```dart
 bool res=await IdallAuthenticator().setIdallConfig('client_id','openid offline_access'); //define application scopes, 
//add openid if you want authorization, add offline_access if you want refresh token
```

to launch login page and get token from idall use: `authenticate`

```dart
bool res=await IdallAuthenticator().authenticate();
```
####use
to get access token, refresh token and expiration date use: `getAccessToken, getRefreshToken, getAccessTokenExpirationDate`
```dart
String accessToken= await IdallAuthenticator().getAccessToken();

String refreshToken= await IdallAuthenticator().getRefreshToken();

int accessTokenExpirationDate=  await IdallAuthenticator().getAccessTokenExpirationDate() ;
```
 to see if client has access token: `hasAccessToken`
 ```dart
 bool hasToken= await IdallAuthenticator().hasAccessToken();
 ```
to refresh token use: `refreshTokenIfExpired`
 ```dart
 bool res= await IdallAuthenticator().refreshTokenIfExpired();
 ```
to force refresh token use: `doRefreshToken`
 ```dart
 bool res= await IdallAuthenticator().doRefreshToken();
 ```
to reset configs use: `reset`
 ```dart
 await IdallAuthenticator().reset();
 ```