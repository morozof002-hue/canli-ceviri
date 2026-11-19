package ru.prikol.snake;

import android.app.Activity;
import android.os.Bundle;
import android.content.Intent;
import android.speech.tts.TextToSpeech;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.view.Window;
import android.view.WindowManager;
import java.util.Locale;

public class MainActivity extends Activity {
    private WebView webView;
    private TextToSpeech tts;
    private volatile boolean ttsReady = false;
    private volatile boolean destroyed = false;
    private volatile String ttsStatus = "Запуск русского голоса…";
    private String pendingLine = null;

    private class SnakeVoice {
        @JavascriptInterface
        public boolean speak(String message) {
            if (message == null || message.trim().isEmpty()) return false;
            synchronized (MainActivity.this) {
                if (destroyed) return false;
                if (!ttsReady || tts == null) {
                    pendingLine = message;
                    return false;
                }
                final String line = message;
                runOnUiThread(() -> speakNow(line));
                return true;
            }
        }

        @JavascriptInterface
        public boolean isReady() {
            return ttsReady;
        }

        @JavascriptInterface
        public String getStatus() {
            return ttsStatus;
        }

        @JavascriptInterface
        public boolean installRussianVoice() {
            try {
                Intent install = new Intent(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA);
                install.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(install);
                return true;
            } catch (Exception e) {
                ttsStatus = "Не удалось открыть установку голосовых данных";
                return false;
            }
        }
    }

    private void speakNow(String message) {
        if (destroyed || tts == null || !ttsReady) return;
        int result = tts.speak(message, TextToSpeech.QUEUE_FLUSH, null, "zzz-snake-" + System.currentTimeMillis());
        if (result == TextToSpeech.ERROR) {
            ttsStatus = "Ошибка запуска синтезатора речи";
            ttsReady = false;
        }
    }

    private void initSpeech() {
        ttsStatus = "Инициализация синтезатора…";
        tts = new TextToSpeech(getApplicationContext(), status -> {
            if (destroyed || tts == null) return;
            if (status != TextToSpeech.SUCCESS) {
                ttsReady = false;
                ttsStatus = "Android не смог запустить синтезатор речи";
                return;
            }
            int language = tts.setLanguage(new Locale("ru", "RU"));
            if (language == TextToSpeech.LANG_MISSING_DATA) {
                ttsReady = false;
                ttsStatus = "Не установлены голосовые данные русского языка. Нажми ПРОВЕРИТЬ ГОЛОС для установки.";
                return;
            }
            if (language == TextToSpeech.LANG_NOT_SUPPORTED) {
                ttsReady = false;
                ttsStatus = "Выбранный синтезатор не поддерживает русский язык. Установи другой движок TTS.";
                return;
            }
            tts.setSpeechRate(1.0f);
            tts.setPitch(0.86f);
            ttsReady = true;
            ttsStatus = "Русский голос готов";
            String queued;
            synchronized (MainActivity.this) {
                queued = pendingLine;
                pendingLine = null;
            }
            if (queued != null) {
                final String line = queued;
                runOnUiThread(() -> speakNow(line));
            }
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        initSpeech();

        webView = new WebView(this);
        webView.setBackgroundColor(0xFF080B18);
        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setDomStorageEnabled(true);
        webView.getSettings().setAllowFileAccess(true);
        webView.addJavascriptInterface(new SnakeVoice(), "snakeVoice");
        webView.setWebViewClient(new WebViewClient());
        webView.setWebChromeClient(new WebChromeClient());
        setContentView(webView);
        webView.loadUrl("file:///android_asset/index.html");
    }

    @Override
    public void onBackPressed() {
        if (webView != null && webView.canGoBack()) webView.goBack();
        else super.onBackPressed();
    }

    @Override
    protected void onDestroy() {
        destroyed = true;
        ttsReady = false;
        if (webView != null) {
            webView.removeJavascriptInterface("snakeVoice");
            webView.destroy();
            webView = null;
        }
        if (tts != null) {
            tts.stop();
            tts.shutdown();
            tts = null;
        }
        super.onDestroy();
    }
}