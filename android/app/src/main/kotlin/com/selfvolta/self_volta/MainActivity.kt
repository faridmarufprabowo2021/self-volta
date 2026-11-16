package com.selfvolta.self_volta

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.OpenableColumns
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

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
    private var pendingPick: MethodChannel.Result? = null

    companion object {
        private const val REQ_PICK_SOUND = 7711
        private const val MAX_CUSTOM_BYTES = 25L * 1024L * 1024L
    }

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
                    "pickCustom" -> pickCustomSound(result)
                    "clearCustom" -> {
                        clearCustomSound()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // ---- Nada alarm kustom dari file milik user ----

    /**
     * Buka pemilih file audio. Hasilnya dikirim balik lewat
     * [onActivityResult] sebagai nama file, atau `null` bila user batal.
     */
    private fun pickCustomSound(result: MethodChannel.Result) {
        if (pendingPick != null) {
            result.error("busy", "Pemilih file masih terbuka.", null)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "audio/*"
        }
        pendingPick = result
        try {
            startActivityForResult(intent, REQ_PICK_SOUND)
        } catch (e: Exception) {
            pendingPick = null
            result.error("picker", e.message ?: "Tidak bisa membuka pemilih file.", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQ_PICK_SOUND) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingPick
        pendingPick = null
        val uri = if (resultCode == Activity.RESULT_OK) data?.data else null
        if (result == null) return
        if (uri == null) {
            // User menutup pemilih tanpa memilih file.
            result.success(null)
            return
        }
        Thread {
            try {
                val name = importSound(uri)
                runOnUiThread { result.success(name) }
            } catch (e: Exception) {
                val msg = e.message ?: "File audio tidak bisa dibaca."
                runOnUiThread { result.error("import", msg, null) }
            }
        }.start()
    }

    /**
     * Salin file pilihan user ke penyimpanan app supaya tetap bisa diputar
     * walau URI aslinya sementara. Nama file asli dikembalikan untuk
     * ditampilkan di UI.
     */
    private fun importSound(uri: Uri): String {
        val displayName = queryDisplayName(uri)?.trim().orEmpty()
        val ext = extensionFor(uri, displayName)
        val target = File(filesDir, "custom_ringtone.$ext")
        val temp = File(filesDir, "custom_ringtone.new")
        var copied = 0L
        try {
            val input = contentResolver.openInputStream(uri)
                ?: throw IllegalStateException("File audio tidak bisa dibuka.")
            input.use { src ->
                FileOutputStream(temp).use { out ->
                    val buf = ByteArray(64 * 1024)
                    while (true) {
                        val n = src.read(buf)
                        if (n <= 0) break
                        copied += n
                        if (copied > MAX_CUSTOM_BYTES) {
                            throw IllegalStateException(
                                "File terlalu besar. Maksimal 25 MB."
                            )
                        }
                        out.write(buf, 0, n)
                    }
                    out.flush()
                }
            }
            if (copied == 0L) {
                throw IllegalStateException("File audio kosong.")
            }
            // Hapus nada lama, tetapi jangan hapus file sementara yang baru
            // saja ditulis.
            clearCustomSound(except = temp.name)
            if (!temp.renameTo(target)) {
                throw IllegalStateException("Gagal menyimpan nada alarm.")
            }
        } catch (e: Exception) {
            temp.delete()
            throw e
        }
        if (displayName.isNotEmpty()) return displayName
        return target.name
    }

    private fun queryDisplayName(uri: Uri): String? {
        return try {
            contentResolver.query(
                uri,
                arrayOf(OpenableColumns.DISPLAY_NAME),
                null,
                null,
                null
            )?.use { c ->
                if (!c.moveToFirst()) return@use null
                val idx = c.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (idx < 0) null else c.getString(idx)
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun extensionFor(uri: Uri, name: String): String {
        val fromName = name.substringAfterLast('.', "")
            .lowercase()
            .filter { it.isLetterOrDigit() }
        if (fromName.isNotEmpty() && fromName.length <= 5) return fromName
        return when (contentResolver.getType(uri)?.lowercase()) {
            "audio/mpeg", "audio/mp3" -> "mp3"
            "audio/mp4", "audio/aac", "audio/x-m4a" -> "m4a"
            "audio/ogg" -> "ogg"
            "audio/wav", "audio/x-wav", "audio/wave" -> "wav"
            "audio/flac", "audio/x-flac" -> "flac"
            else -> "audio"
        }
    }

    /** File nada kustom yang tersimpan, atau `null` bila belum ada. */
    private fun customSoundFile(): File? {
        return try {
            filesDir.listFiles()?.firstOrNull {
                it.name.startsWith("custom_ringtone.") &&
                    !it.name.endsWith(".new") &&
                    it.isFile &&
                    it.length() > 0
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun clearCustomSound(except: String? = null) {
        try {
            filesDir.listFiles()?.forEach {
                if (it.name.startsWith("custom_ringtone") && it.name != except) {
                    it.delete()
                }
            }
        } catch (_: Exception) {
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
            val mp = MediaPlayer()
            mp.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            if (sound == "kustom") {
                // Nada pilihan user dari file HP; fallback ke nada alarm
                // bawaan bila file sudah tidak ada.
                val file = customSoundFile()
                if (file != null) {
                    mp.setDataSource(file.absolutePath)
                } else {
                    val fallback = RingtoneManager.getDefaultUri(
                        RingtoneManager.TYPE_ALARM
                    ) ?: RingtoneManager.getDefaultUri(
                        RingtoneManager.TYPE_NOTIFICATION
                    ) ?: return
                    mp.setDataSource(this, fallback)
                }
            } else {
                val uri = soundUri(sound) ?: return
                mp.setDataSource(this, uri)
            }
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
        pendingPick?.let { it.error("canceled", "Pemilih file ditutup.", null) }
        pendingPick = null
        stopAlarm()
        super.onDestroy()
    }
}
