package com.tebyansmart.idall_in_app_authentication

import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

/** IdallInAppAuthenticationPlugin */
class IdallInAppAuthenticationPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  var TAG = "hamdamTag"
  val CHANNEL = "samples.flutter.io/auth"
  private var methodChannel: MethodChannel? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "idall_in_app_authentication")
    channel.setMethodCallHandler(this)
  }

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    methodChannel = MethodChannel(getFlutterEngine()!!.dartExecutor.binaryMessenger, CHANNEL)


  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)

    val action: String? = intent?.action
    val data: Uri? = intent?.data
    Log.d("deepLing", "onNewIntent:${data.toString()} ")
    methodChannel?.invokeMethod("idallUrl", data.toString())


  }

  override fun onResume() {
    super.onResume()
    val action: String? = intent?.action
    val data: Uri? = intent?.data
    Log.d("deepLing", "resume :${data.toString()} ")
    methodChannel?.invokeMethod("idallUrl", data.toString())

  }
}
