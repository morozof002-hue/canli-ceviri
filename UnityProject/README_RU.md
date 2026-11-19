# NEON COAST — Unity 3D foundation

Отдельный Unity 6 проект, не WebView и не HTML-игра.

## Требования
- Unity 6.0 (6000.0.x), Android Build Support, SDK/NDK и OpenJDK.
- URP, Input System, TextMeshPro, AI Navigation (пакеты подключены в manifest).
- Android: ARM64, IL2CPP, минимум API 26.

## Создание сцены
1. Открой папку `UnityProject` через Unity Hub и дождись импорта.
2. Выбери **NEON COAST → Build First 3D District**.
3. Открой `Assets/Scenes/NeonCoast_District01.unity`, нажми Play. В Project Settings → Player → Other Settings установи Active Input Handling = Both и перезапусти редактор.
4. На ПК: WASD/стрелки, Shift — бег, Space — прыжок. На телефоне — джойстик, SPRINT, JUMP; свайп справа поворачивает камеру.
5. Подойди к машине и нажми ENTER/EXIT, чтобы сесть за руль. В машине управление — тот же джойстик.
6. Для APK выбери **NEON COAST → Configure Android Build**, затем **NEON COAST → Build Android APK**. Файл появится в `Build/Android/NEON-COAST.apk`.

## Состав первой основы
- Процедурный приморский 3D-квартал: сетка улиц, здания, окна/балконы, пальмы, фонари, пляж и море.
- Персонаж от третьего лица, следящая камера и экранное управление.
- Машины с Rigidbody, ускорением, рулением и посадкой/высадкой.
- Базовая система сохранения позиции и профиль производительности Android.

## Проверка и ограничения
Это исходный Unity-проект и генератор сцены. Он ещё не запускался в Unity и не собран в APK; модели и анимации пока блокинговые. URP и остальные пакеты устанавливаются при первом открытии проекта; URP Pipeline Asset пока нужно назначить в Project Settings. Меню APK настраивает ARM64, IL2CPP, landscape и API 26. Перед распространением обязательны проверка компиляции, замена блокинга лицензированными моделями, анимации/звук и Android-профилирование на реальном Honor. Сборка APK из этого чата не выполнялась.
