package ai.lingua.mobile

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

private val Ink = Color(0xFF14221E)
private val Green = Color(0xFF0D8061)
private val AppSurface = Color(0xFFF3F6F4)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) { super.onCreate(savedInstanceState); setContent { LinguaApp() } }
}

@Composable
private fun LinguaApp() {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var source by remember { mutableStateOf("Русский") }
    var target by remember { mutableStateOf("中文") }
    var input by remember { mutableStateOf("") }
    var output by remember { mutableStateOf("Здесь появится перевод.") }
    var status by remember { mutableStateOf("Скачайте Whisper Large V3 Turbo один раз (около 547 МБ).") }
    var modelReady by remember { mutableStateOf(WhisperModel.isInstalled(context)) }
    var busy by remember { mutableStateOf(false) }
    var progress by remember { mutableIntStateOf(0) }
    val recorder = remember { VoiceRecorder() }
    val modelPath = remember(modelReady) { if (modelReady) WhisperModel.modelFile(context).absolutePath else "" }
    val permissionLauncher = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
        status = if (granted) "Микрофон разрешён. Удерживайте кнопку записи." else "Разрешите доступ к микрофону в настройках Android."
    }

    MaterialTheme(colorScheme = lightColorScheme(primary = Green, background = AppSurface)) {
        Surface(Modifier.fillMaxSize(), color = AppSurface) {
            Column(Modifier.fillMaxSize().padding(horizontal = 20.dp, vertical = 22.dp), verticalArrangement = Arrangement.spacedBy(13.dp)) {
                Column {
                    Text("LINGUA AI", fontSize = 30.sp, fontWeight = FontWeight.Black, color = Green)
                    Text("Локальное распознавание речи • Large V3 Turbo", fontSize = 13.sp, color = Ink.copy(alpha = .6f))
                }
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically) {
                    LanguageChip(source, Modifier.weight(1f)) { source = target.also { target = source } }
                    Text("⇄", fontSize = 22.sp, color = Green)
                    LanguageChip(target, Modifier.weight(1f)) { target = when (target) { "中文" -> "English"; "English" -> "Türkçe"; else -> "中文" } }
                }
                Column(Modifier.fillMaxWidth().weight(1f).background(Color.White, RoundedCornerShape(22.dp)).padding(18.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("РАСПОЗНАННАЯ РЕЧЬ / ТЕКСТ", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Green)
                    BasicTextField(input, { input = it }, Modifier.fillMaxWidth().weight(1f), textStyle = TextStyle(fontSize = 18.sp, color = Ink, lineHeight = 26.sp), decorationBox = { inner ->
                        Box { if (input.isEmpty()) Text("Говорите или введите текст…", color = Ink.copy(alpha = .35f), fontSize = 17.sp); inner() }
                    })
                    HorizontalDivider(color = AppSurface)
                    Text("ПЕРЕВОД", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Green)
                    Text(output, fontSize = 17.sp, color = Ink, lineHeight = 25.sp, modifier = Modifier.fillMaxWidth().weight(1f))
                }
                if (!modelReady) {
                    Button(onClick = {
                        busy = true; status = "Загрузка модели Whisper…"
                        scope.launch {
                            try {
                                withContext(Dispatchers.IO) { WhisperModel.download(context) { progress = it } }
                                modelReady = true; status = "Whisper установлен. Распознавание работает офлайн."
                            } catch (e: Exception) { status = "Ошибка загрузки: ${e.message ?: "неизвестно"}" }
                            finally { busy = false }
                        }
                    }, enabled = !busy, modifier = Modifier.fillMaxWidth().height(54.dp), shape = RoundedCornerShape(16.dp)) {
                        Text(if (busy) "ЗАГРУЗКА $progress%" else "СКАЧАТЬ WHISPER TURBO · ~547 МБ")
                    }
                } else {
                    Box(Modifier.fillMaxWidth().height(64.dp).background(Green, RoundedCornerShape(18.dp)).pointerInput(modelPath) {
                        detectTapGestures(onPress = {
                            val allowed = ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED
                            if (!allowed) {
                                permissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
                            } else if (!busy) {
                                val pcm = File(context.cacheDir, "lingua-recording.pcm")
                                var started = false
                                try {
                                    recorder.start(pcm)
                                    started = true
                                    status = "Слушаю… отпустите кнопку для распознавания."
                                    val released = tryAwaitRelease()
                                    val recorded = withContext(NonCancellable + Dispatchers.IO) { recorder.stop() }
                                    started = false
                                    if (!released) {
                                        status = "Запись прервана. Удерживайте кнопку и попробуйте ещё раз."
                                    } else if (recorded != null && recorded.length() > 2_000) {
                                        scope.launch {
                                            busy = true
                                            try {
                                                status = "Распознаю речь локально…"
                                                val language = when (source) { "Русский" -> "ru"; "English" -> "en"; "Türkçe" -> "tr"; "中文" -> "zh"; else -> "auto" }
                                                val recognized = withContext(Dispatchers.IO) {
                                                    NativeWhisper.transcribeNative(recorded.absolutePath, modelPath, language)
                                                }.trim()
                                                input = recognized
                                                status = if (recognized.isBlank()) "Речь не распознана. Попробуйте ещё раз." else "Речь распознана офлайн. Локальный переводчик подключается следующим этапом."
                                            } catch (e: Exception) {
                                                status = "Ошибка распознавания: ${e.message ?: e.javaClass.simpleName}"
                                            } finally {
                                                busy = false
                                            }
                                        }
                                    } else {
                                        status = "Запись слишком короткая. Удерживайте кнопку дольше."
                                    }
                                } catch (e: CancellationException) {
                                    if (started) withContext(NonCancellable + Dispatchers.IO) { recorder.stop() }
                                    throw e
                                } catch (e: Exception) {
                                    if (started) {
                                        try { withContext(NonCancellable + Dispatchers.IO) { recorder.stop() } } catch (_: Exception) { }
                                    }
                                    status = "Ошибка записи: ${e.message ?: e.javaClass.simpleName}"
                                }
                            }
                        })
                    }, contentAlignment = Alignment.Center) {
                        Text(if (busy) "ОБРАБОТКА…" else "●  УДЕРЖИВАЙТЕ И ГОВОРИТЕ", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 15.sp)
                    }
                }
                Text(status, fontSize = 12.sp, color = Ink.copy(alpha = .65f), modifier = Modifier.align(Alignment.CenterHorizontally))
                Text("WHISPER LARGE V3 TURBO • OFFLINE • БЕЗ РЕКЛАМЫ", fontSize = 10.sp, color = Green, fontWeight = FontWeight.Bold, modifier = Modifier.align(Alignment.CenterHorizontally))
            }
        }
    }
}

@Composable
private fun LanguageChip(language: String, modifier: Modifier = Modifier, onClick: () -> Unit) {
    OutlinedButton(onClick = onClick, modifier = modifier.height(50.dp), shape = RoundedCornerShape(15.dp)) {
        Text(language, fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
    }
}
