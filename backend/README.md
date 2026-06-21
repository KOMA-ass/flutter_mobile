# Lava Jump Backend

Необязательный маленький Dart Frog API для таблицы рекордов. Состояние хранится
в памяти и очищается после перезапуска сервера, поэтому база данных не нужна.

## Запуск

```bash
cd backend
dart pub get
dart_frog dev
```

## API

- `GET /` — проверка состояния.
- `GET /scores` — десять лучших результатов.
- `POST /scores` — добавить `{"name":"Player","score":12}`.
