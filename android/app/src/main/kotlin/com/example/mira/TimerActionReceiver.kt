package com.example.mira

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

class TimerActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_PAUSE = "com.example.mira.TIMER_PAUSE"
        const val ACTION_RESUME = "com.example.mira.TIMER_RESUME"
        const val ACTION_STOP = "com.example.mira.TIMER_STOP"
        const val CHANNEL_NAME = "com.example.mira/timer_actions"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return

        val action = when (intent.action) {
            ACTION_PAUSE -> "pause"
            ACTION_RESUME -> "resume"
            ACTION_STOP -> "stop"
            else -> return
        }

        // Send action to Flutter through MethodChannel
        // This requires the Flutter engine to be running
        val sharedPrefs = context.getSharedPreferences("timer_actions", Context.MODE_PRIVATE)
        sharedPrefs.edit().putString("last_action", action).apply()
    }
}
