package com.selfvolta.self_volta

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Activity utama + jembatan alarm layar penuh.
 *
 * Flutter tidak punya pemutar audio looping bawaan, jadi alarm memakai
 * MediaPlayer native yang diulang di stream alarm. Saat alarm aktif activity
 * ditampilkan di atas lockscreen, layar dibangunkan, dan tetap menyala.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "selfvolta/alarm"
    private var player: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        startAlarm(call.argument<String>("sound") ?: "")
                        result.success(null)
                    }
                    "stop" -> {
                        stopAlarm()
                        result.success(null)
                    }
                    "alarmMode" -> {
                        setAlarmMode(call.argument<Boolean>("on") == true)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun soundUri(sound: String): Uri? {
        val res = when (sound) {
            "ding" -> R.raw.notif_ding
            "chime" -> R.raw.notif_chime
            "lembut" -> R.raw.notif_lembut
            else -> 0
        }
        if (res != 0) return Uri.parse("android.resource://$packageName/$res")
        return RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
    }

    private fun startAlarm(sound: String) {
        stopPlayer()
        try {
            val uri = soundUri(sound) ?: return
            val mp = MediaPlayer()
            mp.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            mp.setDataSource(this, uri)
            mp.isLooping = true
            mp.prepare()
            mp.start()
            player = mp
        } catch (_: Exception) {
            stopPlayer()
        }
    }

    private fun stopPlayer() {
        try {
            player?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
        } catch (_: Exception) {
        } finally {
            player = null
        }
    }

    private fun setAlarmMode(on: Boolean) {
        if (on) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(true)
                setTurnScreenOn(true)
            } else {
                @Suppress("DEPRECATION")
                window.addFlags(
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                )
            }
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            acquireWakeLock()
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(false)
                setTurnScreenOn(false)
            } else {
                @Suppress("DEPRECATION")
                window.clearFlags(
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                )
            }
            releaseWakeLock()
        }
    }

    private fun acquireWakeLock() {
        if (wakeLock != null) return
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = pm.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "selfvolta:alarm"
            ).also { it.acquire(10 * 60 * 1000L) }
        } catch (_: Exception) {
            wakeLock = null
        }
    }

    private fun releaseWakeLock() {
        try {
            wakeLock?.let { if (it.isHeld) it.release() }
        } catch (_: Exception) {
        } finally {
            wakeLock = null
        }
    }

    private fun stopAlarm() {
        stopPlayer()
        setAlarmMode(false)
    }

    override fun onDestroy() {
        stopAlarm()
        super.onDestroy()
    }
}
