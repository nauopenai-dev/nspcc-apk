# NSPCC Card Calculator (Flutter)

Клиентский калькулятор стоимости тиража карт (Android APK).

## Сборка APK через GitHub Actions
1. Создай репозиторий `nspcc-apk` и загрузи туда этот проект.
2. Вкладка **Actions** → запустится workflow `Build Flutter APK`.
3. Готовый файл появится в **Actions → последний запуск → Artifacts** (CardCalculator_NSPCC.apk).

## Локально
```bash
flutter pub get
flutter build apk --release
```
