package com.example.pictureinpicture_plugin

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import tv.danmaku.ijk.media.player.IjkMediaPlayer
import java.lang.Exception
import java.util.*
import kotlin.collections.ArrayList


/** PictureinpicturePlugin */
class PictureinpicturePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity


  private lateinit var channel : MethodChannel
  private lateinit var flutterActivity:Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pictureinpicture_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "PIPInt"){


      //加载so文件
      try {


        IjkMediaPlayer.loadLibrariesOnce(null)
        IjkMediaPlayer.native_profileBegin("libijkplayer.so")
      } catch (e: Exception) {

        flutterActivity.finish();
      }
    } else if (call.method == "PIPopen"){


      print(call.arguments);
      val intent:Intent = Intent(flutterActivity,FloatWindowService().javaClass)
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      print(call.arguments)
      val arr:ArrayList<Any> = call.arguments as ArrayList<Any>;
      print(arr[0])
      intent.putExtra("url", arr[0] as String);
      intent.action = FloatWindowService.ACTION_FOLLOW_TOUCH
      flutterActivity.startService(intent)
    }else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    flutterActivity=binding.activity


  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

  }

  override fun onDetachedFromActivity() {

  }
}
