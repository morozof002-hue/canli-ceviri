package ai.lingua.mobile

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val Ink = Color(0xFF14221E)
private val Green = Color(0xFF0D8061)
private val Surface = Color(0xFFF3F6F4)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { LinguaApp() }
    }
}

@Composable
private fun LinguaApp() {
    var source by remember { mutableStateOf("Русский") }
    var target by remember { mutableStateOf("中文") }
    var input by remember { mutableStateOf("") }
    var output by remember { mutableStateOf("Здесь появится перевод.") }
    var status by remember { mutableStateOf("Локальная модель ещё не установлена") }

    MaterialTheme(colorScheme = lightColorScheme(primary = Green, background = Surface)) {
        Surface(modifier = Modifier.fillMaxSize(), color = Surface) {
            Column(
                modifier = Modifier.fillMaxSize().padding(horizontal = 20.dp, vertical = 24.dp),
                verticalArrangement = Arrangement.spacedBy(18.dp)
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("LINGUA AI", fontSize = 30.sp, fontWeight = FontWeight.Black, color = Green)
                    Text("Локальный AI-переводчик", fontSize = 13.sp, color = Ink.copy(alpha = .6f))
                }
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically) {
                    LanguageChip(source, Modifier.weight(1f)) {
                        source = target.also { target = source }
                    }
                    Text("⇄", fontSize = 22.sp, color = Green)
                    LanguageChip(target, Modifier.weight(1f)) {
                        target = if (target == "中文") "English" else "中文"
                    }
                }
                Column(
                    modifier = Modifier.fillMaxWidth().weight(1f).background(Color.White, RoundedCornerShape(22.dp)).padding(18.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text("ВЫ ГОВОРИТЕ", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Green)
                    BasicTextField(
                        value = input, onValueChange = { input = it },
                        modifier = Modifier.fillMaxWidth().weight(1f),
                        textStyle = TextStyle(fontSize = 18.sp, color = Ink, lineHeight = 26.sp),
                        decorationBox = { inner ->
                            Box {
                                if (input.isEmpty()) Text("Введите текст для перевода…", color = Ink.copy(alpha = .35f), fontSize = 17.sp)
                                inner()
                            }
                        }
                    )
                    HorizontalDivider(color = Surface)
                    Text("ПЕРЕВОД", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Green)
                    Text(output, fontSize = 18.sp, color = Ink, lineHeight = 26.sp, modifier = Modifier.fillMaxWidth().weight(1f))
                }
                Button(
                    onClick = { output = "Подключение локальной DeepSeek-модели — следующий этап разработки."; status = "Текст принят. AI-движок ещё подключается." },
                    modifier = Modifier.fillMaxWidth().height(58.dp),
                    shape = RoundedCornerShape(18.dp)
                ) {
                    Text("ПЕРЕВЕСТИ", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                }
                Text(status, fontSize = 12.sp, color = Ink.copy(alpha = .55f), modifier = Modifier.align(Alignment.CenterHorizontally))
                Text("ОФЛАЙН • БЕЗ РЕКЛАМЫ • БЕЗ ПОДПИСКИ", fontSize = 10.sp, color = Green, fontWeight = FontWeight.Bold, modifier = Modifier.align(Alignment.CenterHorizontally))
            }
        }
    }
}

@Composable
private fun LanguageChip(language: String, modifier: Modifier = Modifier, onClick: () -> Unit) {
    OutlinedButton(onClick = onClick, modifier = modifier.height(52.dp), shape = RoundedCornerShape(15.dp)) {
        Text(language, fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
    }
}
