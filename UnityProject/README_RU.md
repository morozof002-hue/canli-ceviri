# NEON COAST — Unity 3D foundation

Это отдельный Unity 6 проект, не WebView и не HTML-игра.

## Требования
- Unity 6.0 LTS (6000.0.x), Android Build Support, Android SDK/NDK и OpenJDK.
- URP, Input System, AI Navigation (пакеты подключены в manifest).
- Для Android: ARM64, IL2CPP, минимум Android 8.0 / API 26.

## Создание первого района
1. Открой папку `UnityProject` через Unity Hub.
2. Дождись импорта URP и пакетов.
3. В меню Unity выбери **NEON COAST → Build First 3D District**.
4. Открой `Assets/Scenes/NeonCoast_District01.unity` и нажми Play.
5. На ПК: WASD/стрелки, Shift — бег, Space — прыжок. На телефоне — экранный джойстик, SPRINT и JUMP; поворот камеры — свайп по правой части экрана.

## Честный статус
Генератор создаёт первый процедурный 3D blockout района: сетку улиц, набережную и море, фасады с окнами/балконами, пальмы, фонари, несколько машин и персонажа с камерой от третьего лица. Это основа для дальнейшей замены блокинга на качественные лицензированные модели, материалов, анимаций, трафика и миссий. Сборка APK здесь ещё не выполнена и проект пока не проходил runtime-тест на Honor.
