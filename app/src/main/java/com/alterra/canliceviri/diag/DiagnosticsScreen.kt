package com.alterra.canliceviri.diag

import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.alterra.canliceviri.BuildConfig
import com.alterra.canliceviri.Languages
import com.alterra.canliceviri.audio.AudioDevices
import com.alterra.canliceviri.audio.Dsp
import com.alterra.canliceviri.audio.TtsEngine
import java.io.File

@Composable
fun DiagnosticsScreen(
    vm: DiagnosticsViewModel,
    onRequestPermission: () -> Unit,
    onShareText: (String) -> Unit,
    onCopyText: (String) -> Unit,
    onShareFiles: (List<File>) -> Unit,
    onOpenTtsSettings: () -> Unit,
    onInstallTtsData: (String?) -> Unit,
    onBack: (() -> Unit)? = null,
) {
    Scaffold { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            if (onBack != null) TextButton(onClick = onBack) { Text("← Вернуться к переводу") }
            Column {
                Text("Живой перевод", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
                Text(
                    "Cihaz testi · ${BuildConfig.VERSION_NAME}",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            if (!vm.hasPermission) {
                Section("Требуется доступ к микрофону", "Для проверки используется микрофон.") {
                    Button(onClick = onRequestPermission) { Text("Разрешить") }
                }
            }
            if (vm.benchLog.isNotEmpty()) {
                Section("Для разработчиков · тест распознавания речи") {
                    vm.benchLog.forEach {
                        Text(it, style = MaterialTheme.typography.bodySmall, fontFamily = FontFamily.Monospace)
                    }
                }
            }
            OneTapCard(vm, onShareText)
            SummaryCard(vm)
            DualMicCard(vm, onShareFiles)
            OutputCard(vm)
            TtsCard(vm, onOpenTtsSettings, onInstallTtsData)
            DevicesCard(vm)
            ReportCard(vm, onShareText, onCopyText)
            Spacer(Modifier.height(24.dp))
        }
    }
}

// ------------------------------------------------------------------ Kartlar

@Composable
private fun OneTapCard(vm: DiagnosticsViewModel, onShareText: (String) -> Unit) {
    Section(
        "Комплексная проверка одной кнопкой",
        "Подключите наушники, установите среднюю громкость мультимедиа и положите телефон на стол. " +
            "Проверка займёт около минуты: вы услышите короткие сигналы и две фразы. Говорить не нужно. По завершении отправьте отчёт.",
    ) {
        Button(
            onClick = vm::runAll,
            enabled = !vm.busy && vm.hasPermission,
            modifier = Modifier.fillMaxWidth(),
        ) { Text(if (vm.allRunning) "Проверка выполняется…" else "Hepsini test et") }
        if (vm.allDone && !vm.busy) {
            Button(onClick = { onShareText(vm.buildReport()) }, modifier = Modifier.fillMaxWidth()) { Text("Отправить отчёт") }
        }
    }
}

@Composable
private fun SummaryCard(vm: DiagnosticsViewModel) {
    Section("Сводка") {
        SummaryRow("Одновременная работа двух микрофонов", vm.dual.verdict)
        SummaryRow("Динамик при подключённых наушниках", vm.output.sequential)
        SummaryRow("Два аудиовыхода одновременно (дополнительно)", vm.output.simultaneous)
        SummaryRow("Вывод озвучивания", vm.ttsState.verdict)
        if (vm.scan.pairVerdict != null) SummaryRow("Tarama: iki mikrofon", vm.scan.pairVerdict)
        if (vm.scan.stereoVerdict != null) SummaryRow("Tarama: telefon stereo", vm.scan.stereoVerdict)
        val statuses = vm.ttsState.statuses
        if (statuses.isNotEmpty()) {
            val ready = statuses.count { it.state == TtsEngine.State.READY }
            Text(
                "Офлайн-озвучивание: готово языков — $ready из ${statuses.size}",
                style = MaterialTheme.typography.bodyMedium,
            )
        }
    }
}

@Composable
private fun DualMicCard(vm: DiagnosticsViewModel, onShareFiles: (List<File>) -> Unit) {
    val d = vm.dual
    val running = vm.busy && d.phase != DualPhase.IDLE && d.phase != DualPhase.DONE
    Section(
        "1 · Одновременная работа двух микрофонов",
        "Могут ли микрофон наушников (A) и микрофон телефона (B) одновременно записывать звук раздельно?",
    ) {
        Picker(
            label = "A · Микрофон наушников",
            items = vm.mics,
            selected = vm.mics.firstOrNull { it.id == vm.selectedA },
            itemLabel = { AudioDevices.describe(it) },
            enabled = !vm.busy,
        ) { vm.selectedA = it.id }
        Picker(
            label = "B · Микрофон телефона",
            items = vm.mics,
            selected = vm.mics.firstOrNull { it.id == vm.selectedB },
            itemLabel = { AudioDevices.describe(it) },
            enabled = !vm.busy,
        ) { vm.selectedB = it.id }
        Picker(
            label = "Источник записи",
            items = AUDIO_SOURCES,
            selected = AUDIO_SOURCES.firstOrNull { it.first == vm.source },
            itemLabel = { it.second },
            enabled = !vm.busy,
        ) { vm.source = it.first }

        Instruction(d.phase, d.secondsLeft)

        if (running || d.phase == DualPhase.DONE && d.levelA > Dsp.FLOOR_DB) {
            LevelBar("A 🎧", d.levelA, MaterialTheme.colorScheme.primary)
            LevelBar("B 📱", d.levelB, MaterialTheme.colorScheme.tertiary)
            Text("Подключено системой · A: ${d.routedA}", style = MaterialTheme.typography.bodySmall)
            Text("Подключено системой · B: ${d.routedB}", style = MaterialTheme.typography.bodySmall)
            if (d.silencedA == true || d.silencedB == true) {
                Text(
                    "⚠️ Система отключила звук · A: ${d.silencedA} · B: ${d.silencedB}",
                    color = MaterialTheme.colorScheme.error,
                    style = MaterialTheme.typography.bodySmall,
                )
            }
        }

        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            if (running) {
                Button(onClick = vm::stopTest) { Text("Остановить") }
            } else {
                Button(onClick = vm::startDualTest, enabled = !vm.busy && vm.hasPermission) { Text("Начать проверку (18 сек.)") }
                OutlinedButton(onClick = vm::startLive, enabled = !vm.busy && vm.hasPermission) { Text("Слушать в реальном времени") }
            }
        }
        VerdictView(d.verdict)
        if (d.detail.isNotEmpty()) Detail(d.detail)
        if (d.recordings.isNotEmpty() && !vm.busy) {
            TextButton(onClick = { onShareFiles(d.recordings) }) { Text("Поделиться записями (2 WAV)") }
        }

        HorizontalDivider()
        val sc = vm.scan
        Text("Автоматическое сканирование", style = MaterialTheme.typography.labelLarge)
        Detail(
            "Говорить не нужно, проверка займёт около 40 секунд. Она проверит сочетания источников записи и определит, при каком варианте два микрофона " +
                "действительно работают раздельно. Также проверяется стереозапись встроенными микрофонами телефона."
        )
        if (sc.step.isNotEmpty()) {
            Text(sc.step, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.primary)
        }
        OutlinedButton(onClick = vm::startScan, enabled = !vm.busy && vm.hasPermission) { Text("Начать сканирование") }
        if (sc.pairVerdict != null) {
            Text("Два микрофона", style = MaterialTheme.typography.labelMedium)
            VerdictView(sc.pairVerdict)
            sc.pairs.forEach { Detail(DiagnosticsViewModel.pairLine(it)) }
        }
        if (sc.stereoVerdict != null) {
            Text("Встроенные микрофоны телефона (стерео)", style = MaterialTheme.typography.labelMedium)
            VerdictView(sc.stereoVerdict)
            sc.stereo.forEach { Detail(DiagnosticsViewModel.stereoLine(it)) }
        }
    }
}

@Composable
private fun Instruction(phase: DualPhase, seconds: Int) {
    val (text, strong) = when (phase) {
        DualPhase.IDLE, DualPhase.DONE ->
            "Подключите гарнитуру с микрофоном и запустите проверку в тихом месте. Тест состоит из двух этапов и длится 18 секунд." to false
        DualPhase.LIVE ->
            "В реальном времени: сначала говорите в микрофон наушников, затем — в нижний торец телефона. Следите, какой индикатор реагирует." to false
        DualPhase.PREP_HEADSET ->
            "Приготовьтесь… $seconds\nДалее: положите телефон на стол или держите его на вытянутой руке. Нужно будет говорить в микрофон наушников." to true
        DualPhase.REC_HEADSET ->
            "🎧 Сейчас говорите в МИКРОФОН НАУШНИКОВ (считайте от 1 до 10) · $seconds" to true
        DualPhase.PREP_PHONE ->
            "Приготовьтесь… $seconds\nДалее: закройте микрофон наушников ладонью или отодвиньте его. Нужно будет говорить в нижний торец телефона." to true
        DualPhase.REC_PHONE ->
            "📱 Сейчас говорите в НИЖНИЙ МИКРОФОН ТЕЛЕФОНА (считайте от 1 до 10) · $seconds" to true
    }
    if (strong) {
        Box(
            Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(MaterialTheme.colorScheme.primaryContainer)
                .padding(12.dp)
        ) {
            Text(
                text,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onPrimaryContainer,
                fontWeight = FontWeight.SemiBold,
            )
        }
    } else {
        Text(text, style = MaterialTheme.typography.bodyMedium)
    }
}

@Composable
private fun OutputCard(vm: DiagnosticsViewModel) {
    val o = vm.output
    Section(
        "2 · Динамик при подключённых наушниках",
        "Турецкая речь должна звучать в наушниках, иностранная — через динамик телефона. Микрофон телефона прослушает сигналы и автоматически оценит результат.",
    ) {
        Text(
            "Подключите наушники и установите среднюю громкость мультимедиа. Вы услышите короткие сигналы.",
            style = MaterialTheme.typography.bodyMedium,
        )
        if (o.step.isNotEmpty()) {
            Text(o.step, style = MaterialTheme.typography.titleMedium, color = MaterialTheme.colorScheme.primary)
        }
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Button(onClick = { vm.startOutputTest(false) }, enabled = !vm.busy && vm.hasPermission) { Text("Проверить по очереди") }
            OutlinedButton(onClick = { vm.startOutputTest(true) }, enabled = !vm.busy && vm.hasPermission) { Text("Одновременно") }
        }
        Text("По очереди", style = MaterialTheme.typography.labelLarge)
        VerdictView(o.sequential)
        if (o.sequentialDetail.isNotEmpty()) Detail(o.sequentialDetail)
        Text("Одновременно (дополнительно)", style = MaterialTheme.typography.labelLarge)
        VerdictView(o.simultaneous)
        if (o.simultaneousDetail.isNotEmpty()) Detail(o.simultaneousDetail)
    }
}

@Composable
private fun TtsCard(vm: DiagnosticsViewModel, onOpenTtsSettings: () -> Unit, onInstallTtsData: (String?) -> Unit) {
    val t = vm.ttsState
    Section(
        "3 · Озвучивание текста (TTS)",
        "Может ли голосовой движок телефона озвучивать каждый язык без интернета и правильно ли направляется звук?",
    ) {
        Picker(
            label = "Голосовой движок",
            items = t.engines,
            selected = t.engines.firstOrNull { it.packageName == t.engine },
            itemLabel = { "${it.label} (${it.packageName})" },
            enabled = !vm.busy,
        ) { vm.initTts(it.packageName) }
        if (!t.ready) Text("Подготовка движка…", style = MaterialTheme.typography.bodyMedium)
        t.statuses.forEach { s ->
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(stateEmoji(s.state), modifier = Modifier.width(28.dp))
                Text("${s.lang.nameTr} (${s.lang.code})", modifier = Modifier.weight(1f), style = MaterialTheme.typography.bodyMedium)
                Text(s.detail, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
            TextButton(onClick = onOpenTtsSettings) { Text("Настройки голоса") }
            TextButton(onClick = { onInstallTtsData(t.engine) }) { Text("Скачать голосовые данные") }
            TextButton(onClick = vm::refreshTtsStatuses) { Text("Обновить") }
        }
        HorizontalDivider()
        Button(
            onClick = { vm.speakTest(toHeadset = true) },
            enabled = !vm.busy && t.ready,
            modifier = Modifier.fillMaxWidth(),
        ) { Text("🎧 Турецкий → наушники") }
        Picker(
            label = "Иностранный язык",
            items = Languages.FOREIGN,
            selected = t.selected,
            itemLabel = { "${it.nameTr} · ${it.nativeName}" },
            enabled = !vm.busy,
        ) { vm.selectTtsLang(it) }
        Button(
            onClick = { vm.speakTest(toHeadset = false) },
            enabled = !vm.busy && t.ready,
            modifier = Modifier.fillMaxWidth(),
        ) { Text("🔊 ${t.selected.nameTr} → динамик") }
        t.headsetResult?.let { Detail(it) }
        t.speakerResult?.let { Detail(it) }
        VerdictView(t.verdict)
    }
}

@Composable
private fun DevicesCard(vm: DiagnosticsViewModel) {
    Section("Аудиоустройства", vm.deviceSummary) {
        Text("Устройства ввода", style = MaterialTheme.typography.labelLarge)
        vm.inputs.forEach { Detail("• ${AudioDevices.describe(it)}") }
        Text("Устройства вывода", style = MaterialTheme.typography.labelLarge)
        vm.outputs.forEach { Detail("• ${AudioDevices.describe(it)}") }
        if (vm.microphones.isNotEmpty()) {
            Text("Физические микрофоны (${vm.microphones.size})", style = MaterialTheme.typography.labelLarge)
            vm.microphones.forEach { Detail("• $it") }
        }
    }
}

@Composable
private fun ReportCard(vm: DiagnosticsViewModel, onShareText: (String) -> Unit, onCopyText: (String) -> Unit) {
    Section("Отчёт", "Чтобы отправить результаты, поделитесь ими или скопируйте.") {
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Button(onClick = { onShareText(vm.buildReport()) }) { Text("Поделиться отчётом") }
            OutlinedButton(onClick = { onCopyText(vm.buildReport()) }) { Text("Копировать") }
        }
        if (vm.log.isNotEmpty()) {
            Text("Журнал", style = MaterialTheme.typography.labelLarge)
            vm.log.takeLast(12).forEach {
                Text(it, style = MaterialTheme.typography.bodySmall, fontFamily = FontFamily.Monospace)
            }
        }
    }
}

// ------------------------------------------------------------------ Yapı taşları

@Composable
private fun Section(title: String, subtitle: String? = null, content: @Composable ColumnScope.() -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLow),
    ) {
        Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
            if (subtitle != null) {
                Text(subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            content()
        }
    }
}

@Composable
private fun Detail(text: String) {
    Text(text, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
}

@Composable
private fun verdictColor(kind: Kind): Color {
    val dark = isSystemInDarkTheme()
    return when (kind) {
        Kind.OK -> if (dark) Color(0xFF81C784) else Color(0xFF2E7D32)
        Kind.WARN -> if (dark) Color(0xFFFFB74D) else Color(0xFF9A5B00)
        Kind.FAIL -> MaterialTheme.colorScheme.error
    }
}

private fun verdictEmoji(kind: Kind) = when (kind) {
    Kind.OK -> "✅"
    Kind.WARN -> "⚠️"
    Kind.FAIL -> "❌"
}

private fun stateEmoji(s: TtsEngine.State) = when (s) {
    TtsEngine.State.READY -> "✅"
    TtsEngine.State.NEEDS_DOWNLOAD -> "⬇️"
    TtsEngine.State.NETWORK_ONLY -> "🌐"
    TtsEngine.State.UNSUPPORTED -> "❌"
    TtsEngine.State.UNKNOWN -> "❔"
}

@Composable
private fun VerdictView(v: Verdict?) {
    if (v == null) {
        Text("Ещё не проверено", style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        return
    }
    Row {
        Text(verdictEmoji(v.kind), modifier = Modifier.width(28.dp))
        Text(v.text, color = verdictColor(v.kind), fontWeight = FontWeight.Medium, style = MaterialTheme.typography.bodyLarge)
    }
}

@Composable
private fun SummaryRow(label: String, v: Verdict?) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text(v?.let { verdictEmoji(it.kind) } ?: "○", modifier = Modifier.width(28.dp))
        Text(label, style = MaterialTheme.typography.bodyLarge)
    }
}

@Composable
private fun LevelBar(label: String, db: Float, color: Color) {
    val fraction = ((db + 70f) / 70f).coerceIn(0f, 1f)
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text(label, modifier = Modifier.width(48.dp), style = MaterialTheme.typography.bodyMedium)
        Box(
            Modifier
                .weight(1f)
                .height(16.dp)
                .clip(RoundedCornerShape(8.dp))
                .background(MaterialTheme.colorScheme.surfaceVariant)
        ) {
            Box(
                Modifier
                    .fillMaxHeight()
                    .fillMaxWidth(fraction)
                    .background(color)
            )
        }
        Text(
            if (db <= Dsp.FLOOR_DB + 1f) "—" else "%.0f dB".format(db),
            modifier = Modifier.width(64.dp),
            textAlign = TextAlign.End,
            style = MaterialTheme.typography.bodySmall,
        )
    }
}

@Composable
private fun <T> Picker(
    label: String,
    items: List<T>,
    selected: T?,
    itemLabel: (T) -> String,
    enabled: Boolean,
    onSelect: (T) -> Unit,
) {
    var open by remember { mutableStateOf(false) }
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(label, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Box {
            OutlinedButton(
                onClick = { open = true },
                enabled = enabled && items.isNotEmpty(),
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(
                    selected?.let(itemLabel) ?: "Не выбрано",
                    modifier = Modifier.weight(1f),
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
                Text(" ▾")
            }
            DropdownMenu(expanded = open, onDismissRequest = { open = false }) {
                items.forEach { item ->
                    DropdownMenuItem(
                        text = { Text(itemLabel(item)) },
                        onClick = {
                            open = false
                            onSelect(item)
                        },
                    )
                }
            }
        }
    }
}
