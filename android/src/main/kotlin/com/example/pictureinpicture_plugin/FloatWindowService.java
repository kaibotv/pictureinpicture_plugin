package com.example.pictureinpicture_plugin;

import android.app.ActionBar;
import android.app.Service;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Build;
import android.os.IBinder;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;

import tv.danmaku.ijk.media.player.IMediaPlayer;


public class FloatWindowService extends Service {

    public static final String ACTION_FOLLOW_TOUCH = "action_follow_touch";
    WindowManager windowManager;
    WindowManager.LayoutParams layoutParams;
    @Override
    public void onCreate() {
        super.onCreate();
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
//        IjkMediaPlayer.loadLibrariesOnce(null);
//        IjkMediaPlayer.native_profileBegin("libijkplayer.so");
        layoutParams = new WindowManager.LayoutParams();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            layoutParams.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            layoutParams.type = WindowManager.LayoutParams.TYPE_PHONE;
        }
        layoutParams.format = PixelFormat.TRANSPARENT;
        layoutParams.gravity = Gravity.TOP | Gravity.LEFT;
        layoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        layoutParams.width = 300;
        layoutParams.height = 300;
        layoutParams.x = 0;
        layoutParams.y = 0;
    }
    private int mScaledTouchSlop;

    private class FloatingOnTouchListener implements View.OnTouchListener {
        private float mLastY;
        private float mLastX;
        private float mDownY;
        private float mDownX;

        @Override
        public boolean onTouch(View v, MotionEvent event) {
            float x = event.getRawX();
            float y = event.getRawY();
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    mDownX = x;
                    mDownY = y;
                    mLastX = x;
                    mLastY = y;
                    break;
                case MotionEvent.ACTION_MOVE:

                    float moveX = x - mLastX;
                    float moveY = y - mLastY;

                    layoutParams.x += moveX;
                    layoutParams.y += moveY;

                    windowManager.updateViewLayout(v, layoutParams);

                    mLastX = x;
                    mLastY = y;
                    break;
                case MotionEvent.ACTION_UP:
                    float disX = x - mDownX;
                    float disY = y - mDownY;
                    double sqrt = Math.sqrt(Math.pow(disX, 2) + Math.pow(disY, 2));
//                    if (sqrt < mScaledTouchSlop) {
//                        jumpHome();
//                    }
                    break;
            }

            return false;
        }
    }
    private void jumpHome() {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_MAIN);
        intent.addCategory(Intent.CATEGORY_HOME);
        getApplicationContext().startActivity(intent);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {


//        IjkVideoView videoView = (IjkVideoView) inflater.inflate(R.layout.follow_touch_view,null);
//
//        videoView.setVideoURI(Uri.parse("http://106.36.45.36/live.aishang.ctlcdn.com/00000110240001_1/encoder/1/playlist.m3u8"));
//
//        videoView.setOnPreparedListener(new IMediaPlayer.OnPreparedListener() {
//            @Override
//            public void onPrepared(IMediaPlayer mp) {
//                videoView.start();
//            }
//        });
//        windowManager.addView(videoView, layoutParams);

        LayoutInflater layoutInflater = LayoutInflater.from(getApplicationContext());
        //这里使用的是Demo中提供的AndroidMediaController类控制播放相关操作

        final VideoPlayerIJK ijkPlayer = (VideoPlayerIJK) layoutInflater.inflate(R.layout.follow_touch_view,null);
        ijkPlayer.setVideoPath("http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4");
        ijkPlayer.setOnPreparedListener(new IMediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(IMediaPlayer iMediaPlayer) {

                float w = iMediaPlayer.getVideoWidth();
                float h = iMediaPlayer.getVideoHeight();
                float scale = w/h;

                FrameLayout.LayoutParams layoutParams1 = new FrameLayout.LayoutParams(320,
                        (int) (320/scale));
                ijkPlayer.surfaceView.setLayoutParams(layoutParams1);
                layoutParams.width = 320;
                layoutParams.height =  (int) (320/scale);
                windowManager.updateViewLayout(ijkPlayer, layoutParams);
                iMediaPlayer.start();
            }
        });
        ijkPlayer.setOnCompletionListener(new IMediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(IMediaPlayer iMediaPlayer) {
                iMediaPlayer.seekTo(0);
                iMediaPlayer.start();
            }
        });

        mScaledTouchSlop = ViewConfiguration.get(getApplicationContext()).getScaledTouchSlop();
        ijkPlayer.setOnTouchListener(new FloatingOnTouchListener());

        windowManager.addView(ijkPlayer,layoutParams);
        return super.onStartCommand(intent, flags, startId);
    }


    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
