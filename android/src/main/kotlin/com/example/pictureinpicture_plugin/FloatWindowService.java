package com.example.pictureinpicture_plugin;
import android.app.Activity;
import android.app.ActivityManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.IBinder;
import android.util.DisplayMetrics;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import java.util.List;

import tv.danmaku.ijk.media.player.IMediaPlayer;


public class FloatWindowService extends Service {
    public static final String ACTION_FOLLOW_TOUCH = "action_follow_touch";
    Activity baseActivity;
    WindowManager windowManager;
    WindowManager.LayoutParams layoutParams;
    RelativeLayout relativeLayout;
    VideoPlayerIJK ijkPlayer;
    int videoWidht;
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

        DisplayMetrics outMetrics = new DisplayMetrics();
        windowManager.getDefaultDisplay().getMetrics(outMetrics);
        videoWidht = outMetrics.widthPixels/2;
        layoutParams.x =  outMetrics.widthPixels - videoWidht;
        layoutParams.y = outMetrics.heightPixels - (videoWidht/16*9) - 150;

        layoutParams.width = videoWidht;
        layoutParams.height = videoWidht/16*9;

    }

    private class FloatingOnTouchListener implements View.OnTouchListener {

        final GestureDetector gestureDetector = new GestureDetector(getApplicationContext(), new GestureDetector.SimpleOnGestureListener() {

            /**
             * 发生确定的单击时执行
             * @param e
             * @return
             */
            @Override
            public boolean onSingleTapConfirmed(MotionEvent e) {//单击事件

                if (!isAppRunningForeground(getApplicationContext())) {

                    remove();
                    Intent intent = getApplicationContext().getPackageManager().getLaunchIntentForPackage(getApplicationContext().getPackageName());
                    getApplicationContext().startActivity(intent);
                }

                return super.onSingleTapConfirmed(e);
            }

        });

        private int x;
        private int y;

        @Override
        public boolean onTouch(View view, MotionEvent event) {

            gestureDetector.onTouchEvent(event);
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    x = (int) event.getRawX();
                    y = (int) event.getRawY();
                    break;
                case MotionEvent.ACTION_MOVE:
                    int nowX = (int) event.getRawX();
                    int nowY = (int) event.getRawY();
                    int movedX = nowX - x;
                    int movedY = nowY - y;
                    x = nowX;
                    y = nowY;
                    layoutParams.x = layoutParams.x + movedX;
                    layoutParams.y = layoutParams.y + movedY;
                    windowManager.updateViewLayout(view, layoutParams);
                    break;
                default:
                    break;
            }
            return true;
        }
    }

    @Override
    public int onStartCommand(final Intent intent, int flags, int startId) {


        remove();

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

        relativeLayout = (RelativeLayout) layoutInflater.inflate(R.layout.follow_touch_view,null);
        String url = intent.getStringExtra("url");
        ijkPlayer = relativeLayout.findViewById(R.id.ijk_player);
        ijkPlayer.setVideoPath(url);
        ijkPlayer.setOnPreparedListener(new IMediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(IMediaPlayer mp) {
                float w = mp.getVideoWidth();
                float h = mp.getVideoHeight();
                float scale = w/h;


                layoutParams.width = videoWidht;
                layoutParams.height =  (int) (videoWidht/scale);


                ijkPlayer.surfaceView.setBackgroundColor(Color.TRANSPARENT);

                windowManager.updateViewLayout(relativeLayout, layoutParams);
                mp.start();
            }
        });
        ijkPlayer.setOnCompletionListener(new IMediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(IMediaPlayer mp) {

                mp.seekTo(0);
                mp.start();

            }
        });
        DisplayMetrics outMetrics = new DisplayMetrics();
        windowManager.getDefaultDisplay().getMetrics(outMetrics);
        relativeLayout.setOnTouchListener(new FloatingOnTouchListener());
        FrameLayout.LayoutParams layoutParams1 = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT);

        ijkPlayer.surfaceView.setBackgroundColor(Color.BLACK);
        ijkPlayer.surfaceView.setLayoutParams(layoutParams1);


        ImageView close_btn = relativeLayout.findViewById(R.id.close_btn);
        close_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                remove();
            }
        });

        windowManager.addView(relativeLayout,layoutParams);

        return super.onStartCommand(intent, flags, startId);
    }


    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    public void remove() {
        if (relativeLayout != null && windowManager != null) {

            DisplayMetrics outMetrics = new DisplayMetrics();
            windowManager.getDefaultDisplay().getMetrics(outMetrics);
            layoutParams.x =  outMetrics.widthPixels - videoWidht;
            layoutParams.y = outMetrics.heightPixels - (videoWidht/16*9) - 150;

            windowManager.removeView(relativeLayout);
            ijkPlayer.reset();
            relativeLayout = null;

        }
    }
    private boolean isAppRunningForeground(Context context) {
        ActivityManager activityManager = (ActivityManager)context.getSystemService(Context.ACTIVITY_SERVICE);

        assert activityManager != null;
        List<ActivityManager.RunningAppProcessInfo> runningAppProcessList = activityManager.getRunningAppProcesses();

        for (ActivityManager.RunningAppProcessInfo runningAppProcessInfo : runningAppProcessList) {
            if (runningAppProcessInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                    && runningAppProcessInfo.processName.equals(context.getApplicationInfo().processName)) {
                return true;
            }
        }

        return false;
    }
}
