package com.alterra.canliceviri

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

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
            MaterialTheme {
                HuanHome(
                    initialSource = coreLanguages.firstOrNull { it.code == savedSource } ?: coreLanguages[0],
                    initialTarget = coreLanguages.firstOrNull { it.code == savedTarget } ?: coreLanguages[2],
                    initialMode = savedMode,
                    initialAutoDetect = savedAutoDetect,
                    onSave = { source, target, mode, autoDetect ->
                        prefs.edit()
                            .putString("language_1", source.code)
                            .putString("language_2", target.code)
                            .putInt("control_mode", mode)
                            .putBoolean("auto_detect", autoDetect)
                            .apply()
                    },
                    onMicPlaceholder = {
                        Toast.makeText(
                            this,
                            "Подключение распознавания речи — следующий этап разработки",
                            Toast.LENGTH_LONG
                        ).show()
                    }
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
    onSave: (HuanLanguage, HuanLanguage, Int, Boolean) -> Unit,
    onMicPlaceholder: () -> Unit
) {
    var source by remember { mutableStateOf(initialSource) }
    var target by remember { mutableStateOf(initialTarget) }
    var mode by remember { mutableStateOf(initialMode) }
    var autoDetect by remember { mutableStateOf(initialAutoDetect) }
    var settingsOpen by remember { mutableStateOf(false) }
    var historyText by remember { mutableStateOf("Здесь будут отображаться распознанная речь и перевод.") }

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

            Spacer(Modifier.height(28.dp))

            Text("Выберите, кто говорит", fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = Color(0xFF17233B))
            Spacer(Modifier.height(14.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxWidth()) {
                LanguageCard(
                    language = source,
                    number = "ЯЗЫК 1",
                    color = Color(0xFF2457C5),
                    modifier = Modifier.weight(1f),
                    onClick = onMicPlaceholder
                )
                LanguageCard(
                    language = target,
                    number = "ЯЗЫК 2",
                    color = Color(0xFF087E65),
                    modifier = Modifier.weight(1f),
                    onClick = onMicPlaceholder
                )
            }

            Spacer(Modifier.height(12.dp))
            Text(
                "Нажмите кнопку нужного языка, чтобы начать разговор",
                fontSize = 12.sp,
                color = Color(0xFF667085),
                textAlign = TextAlign.Center
            )

            Spacer(Modifier.height(24.dp))
            Card(
                modifier = Modifier.fillMaxWidth().weight(1f),
                shape = RoundedCornerShape(22.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White)
            ) {
                Column(modifier = Modifier.fillMaxSize().padding(18.dp)) {
                    Text("ПЕРЕВОД", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color(0xFF667085), letterSpacing = 1.5.sp)
                    Spacer(Modifier.height(12.dp))
                    Text(historyText, fontSize = 16.sp, color = Color(0xFF344054), lineHeight = 24.sp)
                    Spacer(Modifier.weight(1f))
                    OutlinedButton(
                        onClick = { historyText = "Здесь будут отображаться распознанная речь и перевод." },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("Очистить экран")
                    }
                }
            }

            Spacer(Modifier.height(16.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Режим:", color = Color(0xFF667085), fontSize = 13.sp)
                Text(
                    controlModes[mode],
                    modifier = Modifier.padding(start = 6.dp),
                    color = Color(0xFF344054),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium
                )
            }
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
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        modifier = modifier.height(164.dp),
        shape = RoundedCornerShape(20.dp),
        colors = ButtonDefaults.buttonColors(containerColor = color),
        contentPadding = androidx.compose.foundation.layout.PaddingValues(12.dp)
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
            Text(number, fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color.White.copy(alpha = 0.8f))
            Spacer(Modifier.height(10.dp))
            Text(language.flag, fontSize = 34.sp)
            Spacer(Modifier.height(7.dp))
            Text(language.title, fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White, textAlign = TextAlign.Center)
            Text("НАЖАТЬ", fontSize = 10.sp, color = Color.White.copy(alpha = 0.8f))
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
                        Text("Определять, на каком языке говорят", fontSize = 11.sp, color = Color(0xFF667085))
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
