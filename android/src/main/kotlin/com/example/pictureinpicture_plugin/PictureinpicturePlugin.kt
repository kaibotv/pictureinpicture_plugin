package com.example.pictureinpicture_plugin

import android.app.Activity
import android.app.AlertDialog
import android.content.DialogInterface
import android.content.Intent
import android.os.Build
import android.provider.Settings
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
class PictureinpicturePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity


    private lateinit var channel: MethodChannel
    private lateinit var flutterActivity: Activity

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pictureinpicture_plugin")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "PIPInt") {


            //加载so文件
//      try {
//
//
//        IjkMediaPlayer.loadLibrariesOnce(null)
//        IjkMediaPlayer.native_profileBegin("libijkplayer.so")
//      } catch (e: Exception) {
//
//        flutterActivity.finish();
//      }
        } else if (call.method == "PIPopen") {


            print(call.arguments);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (Settings.canDrawOverlays(flutterActivity)) {

                  startService(call)
                }else {

                    showOpenPermissionDialog(call)

                }
            } else {
                TODO("VERSION.SDK_INT < M")

              startService(call)
            }

        } else {
            result.notImplemented()
        }
    }

    private fun showOpenPermissionDialog(@NonNull call: MethodCall) {
        val builder: AlertDialog.Builder = AlertDialog.Builder(flutterActivity)

        builder.setMessage("小窗播放视频需要在应用设置中开启悬浮权限，是否前往开启权限？")
        builder.setPositiveButton("是",
            DialogInterface.OnClickListener { dialog, which ->
                dialog.dismiss()
                FloatWindowParamManager.tryJumpToPermissionPage(flutterActivity)
            })
        builder.setNegativeButton("否",
            DialogInterface.OnClickListener { dialog, which -> dialog.dismiss() })
        builder.show()
    }

  fun startService(@NonNull call: MethodCall) {

    val intent: Intent = Intent(flutterActivity, FloatWindowService().javaClass)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    val arr: ArrayList<Any> = call.arguments as ArrayList<Any>
    intent.putExtra("url", arr[0] as String)
    intent.action = FloatWindowService.ACTION_FOLLOW_TOUCH
    flutterActivity.startService(intent)
  }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        flutterActivity = binding.activity


    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivity() {

    }
}
