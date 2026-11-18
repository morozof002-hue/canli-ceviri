package com.alterra.canliceviri

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.waitForUpOrCancellation
import androidx.compose.foundation.pointerInput
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat

private data class HuanLanguage(val code: String, val title: String, val flag: String)

private val coreLanguages = listOf(
    HuanLanguage("ru", "Русский", "🇷🇺"),
    HuanLanguage("zh", "中文", "🇨🇳"),
    HuanLanguage("tr", "Türkçe", "🇹🇷"),
    HuanLanguage("en", "English", "🇬🇧")
)

private val controlModes = listOf(
    "Нажать — начать / нажать — закончить",
    "Удерживать кнопку во время речи",
    "Автоматически завершать по паузе"
)

class MainActivity : ComponentActivity() {
    private val prefs by lazy { getSharedPreferences("huan_settings", MODE_PRIVATE) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val savedSource = prefs.getString("language_1", "ru") ?: "ru"
        val savedTarget = prefs.getString("language_2", "tr") ?: "tr"
        val savedMode = prefs.getInt("control_mode", 0).coerceIn(0, 2)
        val savedAutoDetect = prefs.getBoolean("auto_detect", true)

        setContent {
            val controller = remember { HuanSpeechController(applicationContext) }
            val speechState by controller.state.collectAsState()
            var pendingLanguage by remember { mutableStateOf<String?>(null) }
            var pendingAutoFinish by remember { mutableStateOf(false) }
            val permissionLauncher = rememberLauncherForActivityResult(
                ActivityResultContracts.RequestPermission()
            ) { granted ->
                if (granted) controller.startRecording(pendingLanguage, pendingAutoFinish)
            }
            DisposableEffect(controller) {
                onDispose { controller.close() }
            }

            MaterialTheme {
                HuanHome(
                    initialSource = coreLanguages.firstOrNull { it.code == savedSource } ?: coreLanguages[0],
                    initialTarget = coreLanguages.firstOrNull { it.code == savedTarget } ?: coreLanguages[2],
                    initialMode = savedMode,
                    initialAutoDetect = savedAutoDetect,
                    speechState = speechState,
                    onSave = { source, target, mode, autoDetect ->
                        prefs.edit()
                            .putString("language_1", source.code)
                            .putString("language_2", target.code)
                            .putInt("control_mode", mode)
                            .putBoolean("auto_detect", autoDetect)
                            .apply()
                    },
                    onDownloadModel = controller::downloadModel,
                    onStart = { language, autoFinish ->
                        pendingLanguage = language
                        pendingAutoFinish = autoFinish
                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
                            controller.startRecording(language, autoFinish)
                        } else {
                            permissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
                        }
                    },
                    onStop = controller::stopRecording
                )
            }
        }
    }
}

@Composable
private fun HuanHome(
    initialSource: HuanLanguage,
    initialTarget: HuanLanguage,
    initialMode: Int,
    initialAutoDetect: Boolean,
    speechState: HuanSpeechState,
    onSave: (HuanLanguage, HuanLanguage, Int, Boolean) -> Unit,
    onDownloadModel: () -> Unit,
    onStart: (String?, Boolean) -> Unit,
    onStop: () -> Unit
) {
    var source by remember { mutableStateOf(initialSource) }
    var target by remember { mutableStateOf(initialTarget) }
    var mode by remember { mutableStateOf(initialMode) }
    var autoDetect by remember { mutableStateOf(initialAutoDetect) }
    var settingsOpen by remember { mutableStateOf(false) }
    var activeLanguage by remember { mutableStateOf<String?>(null) }

    Surface(modifier = Modifier.fillMaxSize(), color = Color(0xFFF4F6FA)) {
        Column(
            modifier = Modifier.fillMaxSize().padding(horizontal = 20.dp, vertical = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("HUAN", fontSize = 30.sp, fontWeight = FontWeight.ExtraBold, color = Color(0xFF17233B))
                    Text("ПЕРЕВОДЧИК", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color(0xFF667085), letterSpacing = 2.sp)
                }
                TextButton(onClick = { settingsOpen = true }) {
                    Text("⚙ Настройки", color = Color(0xFF344054))
                }
            }

            Spacer(Modifier.height(24.dp))
            Text("Выберите, кто говорит", fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = Color(0xFF17233B))
            Spacer(Modifier.height(14.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxWidth()) {
                LanguageCard(
                    language = source,
                    number = "ЯЗЫК 1",
                    color = Color(0xFF2457C5),
                    modifier = Modifier.weight(1f),
                    mode = mode,
                    active = speechState.recording && activeLanguage == source.code,
                    onClick = {
                        if (speechState.recording) {
                            activeLanguage = null
                            onStop()
                        } else {
                            activeLanguage = source.code
                            onStart(if (autoDetect) null else source.code, mode == 2)
                        }
                    },
                    onPressStart = {
                        activeLanguage = source.code
                        onStart(if (autoDetect) null else source.code, false)
                    },
                    onPressEnd = {
                        activeLanguage = null
                        onStop()
                    }
                )
                LanguageCard(
                    language = target,
                    number = "ЯЗЫК 2",
                    color = Color(0xFF087E65),
                    modifier = Modifier.weight(1f),
                    mode = mode,
                    active = speechState.recording && activeLanguage == target.code,
                    onClick = {
                        if (speechState.recording) {
                            activeLanguage = null
                            onStop()
                        } else {
                            activeLanguage = target.code
                            onStart(if (autoDetect) null else target.code, mode == 2)
                        }
                    },
                    onPressStart = {
                        activeLanguage = target.code
                        onStart(if (autoDetect) null else target.code, false)
                    },
                    onPressEnd = {
                        activeLanguage = null
                        onStop()
                    }
                )
            }

            Spacer(Modifier.height(10.dp))
            Text(
                when (mode) {
                    1 -> "Удерживайте кнопку, пока говорите"
                    2 -> "Приложение само остановится после паузы"
                    else -> "Нажмите для начала и повторно для остановки"
                },
                fontSize = 12.sp,
                color = Color(0xFF667085),
                textAlign = TextAlign.Center
            )

            Spacer(Modifier.height(16.dp))
            Text(speechState.status, fontSize = 13.sp, color = Color(0xFF344054), textAlign = TextAlign.Center)
            if (speechState.downloading) {
                Spacer(Modifier.height(8.dp))
                LinearProgressIndicator(progress = { speechState.downloadProgress / 100f }, modifier = Modifier.fillMaxWidth())
                Text("${speechState.downloadProgress}% · модель Whisper", fontSize = 11.sp, color = Color(0xFF667085))
            }
            if (!speechState.modelReady && !speechState.downloading) {
                Spacer(Modifier.height(8.dp))
                OutlinedButton(onClick = onDownloadModel, modifier = Modifier.fillMaxWidth()) {
                    Text("Скачать модель распознавания (~466 МБ)")
                }
            }
            speechState.error?.let {
                Spacer(Modifier.height(6.dp))
                Text(it, color = Color(0xFFB42318), fontSize = 12.sp, textAlign = TextAlign.Center)
            }

            Spacer(Modifier.height(16.dp))
            Card(
                modifier = Modifier.fillMaxWidth().weight(1f),
                shape = RoundedCornerShape(22.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White)
            ) {
                Column(modifier = Modifier.fillMaxSize().padding(18.dp)) {
                    Text("ВЫ СКАЗАЛИ", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color(0xFF667085), letterSpacing = 1.5.sp)
                    Spacer(Modifier.height(8.dp))
                    Text(speechState.sourceText.ifBlank { "Распознанная речь появится здесь." }, fontSize = 16.sp, color = Color(0xFF344054), lineHeight = 23.sp)
                    Spacer(Modifier.height(16.dp))
                    Text("ПЕРЕВОД", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color(0xFF087E65), letterSpacing = 1.5.sp)
                    Spacer(Modifier.height(8.dp))
                    Text(speechState.translatedText.ifBlank { "Перевод появится здесь и будет произнесён вслух." }, fontSize = 18.sp, fontWeight = FontWeight.Medium, color = Color(0xFF17233B), lineHeight = 26.sp)
                    Spacer(Modifier.weight(1f))
                    OutlinedButton(
                        onClick = { activeLanguage = null },
                        modifier = Modifier.fillMaxWidth()
                    ) { Text("Очистить экран") }
                }
            }

            Spacer(Modifier.height(12.dp))
            Text(
                if (speechState.processing) "Обработка на телефоне…" else "Распознавание — локально · Перевод — после загрузки языковых моделей",
                fontSize = 10.sp,
                color = Color(0xFF667085),
                textAlign = TextAlign.Center
            )
        }
    }

    if (settingsOpen) {
        SettingsDialog(
            source = source,
            target = target,
            mode = mode,
            autoDetect = autoDetect,
            onDismiss = { settingsOpen = false },
            onApply = { newSource, newTarget, newMode, newAutoDetect ->
                source = newSource
                target = newTarget
                mode = newMode
                autoDetect = newAutoDetect
                onSave(newSource, newTarget, newMode, newAutoDetect)
                settingsOpen = false
            }
        )
    }
}

@Composable
private fun LanguageCard(
    language: HuanLanguage,
    number: String,
    color: Color,
    modifier: Modifier,
    mode: Int,
    active: Boolean,
    onClick: () -> Unit,
    onPressStart: () -> Unit,
    onPressEnd: () -> Unit
) {
    val gestureModifier = if (mode == 1) {
        Modifier.pointerInput(language.code) {
            awaitEachGesture {
                awaitFirstDown()
                onPressStart()
                try {
                    waitForUpOrCancellation()
                } finally {
                    onPressEnd()
                }
            }
        }
    } else Modifier

    Button(
        onClick = if (mode == 1) ({}) else onClick,
        modifier = modifier.height(164.dp).then(gestureModifier),
        shape = RoundedCornerShape(20.dp),
        colors = ButtonDefaults.buttonColors(containerColor = if (active) Color(0xFFB54708) else color),
        contentPadding = androidx.compose.foundation.layout.PaddingValues(12.dp)
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
            Text(number, fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color.White.copy(alpha = 0.8f))
            Spacer(Modifier.height(10.dp))
            Text(language.flag, fontSize = 34.sp)
            Spacer(Modifier.height(7.dp))
            Text(language.title, fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White, textAlign = TextAlign.Center)
            Text(if (active) "СЛУШАЮ…" else if (mode == 1) "УДЕРЖИВАТЬ" else "НАЖАТЬ", fontSize = 10.sp, color = Color.White.copy(alpha = 0.85f))
        }
    }
}

@Composable
private fun SettingsDialog(
    source: HuanLanguage,
    target: HuanLanguage,
    mode: Int,
    autoDetect: Boolean,
    onDismiss: () -> Unit,
    onApply: (HuanLanguage, HuanLanguage, Int, Boolean) -> Unit
) {
    var selectedSource by remember { mutableStateOf(source) }
    var selectedTarget by remember { mutableStateOf(target) }
    var selectedMode by remember { mutableStateOf(mode) }
    var selectedAutoDetect by remember { mutableStateOf(autoDetect) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Настройки перевода") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Язык 1", fontWeight = FontWeight.Bold)
                LanguageDropdown(selectedSource) { selectedSource = it }
                Text("Язык 2", fontWeight = FontWeight.Bold)
                LanguageDropdown(selectedTarget) { selectedTarget = it }
                Spacer(Modifier.height(4.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Автоопределение языка", fontWeight = FontWeight.Bold)
                        Text("Распознавать один из выбранных языков автоматически", fontSize = 11.sp, color = Color(0xFF667085))
                    }
                    Switch(checked = selectedAutoDetect, onCheckedChange = { selectedAutoDetect = it })
                }
                Text("Управление микрофоном", fontWeight = FontWeight.Bold)
                controlModes.forEachIndexed { index, label ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        RadioButton(selected = selectedMode == index, onClick = { selectedMode = index })
                        Text(label, fontSize = 12.sp)
                    }
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    val safeTarget = if (selectedTarget.code == selectedSource.code) {
                        coreLanguages.first { it.code != selectedSource.code }
                    } else selectedTarget
                    onApply(selectedSource, safeTarget, selectedMode, selectedAutoDetect)
                }
            ) { Text("Сохранить") }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Отмена") } }
    )
}

@Composable
private fun LanguageDropdown(selected: HuanLanguage, onSelected: (HuanLanguage) -> Unit) {
    var expanded by remember { mutableStateOf(false) }
    OutlinedButton(onClick = { expanded = true }, modifier = Modifier.fillMaxWidth()) {
        Text("${selected.flag}  ${selected.title}")
    }
    DropdownMenu(expanded = expanded, onDismissRequest = { expanded = false }) {
        coreLanguages.forEach { language ->
            DropdownMenuItem(
                text = { Text("${language.flag}  ${language.title}") },
                onClick = {
                    onSelected(language)
                    expanded = false
                }
            )
        }
    }
}
