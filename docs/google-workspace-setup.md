# Подключение Google Workspace к Mirage

## Что подключается

Mirage поддерживает отдельные Google Workspace mounts:

| Mount | Resource | Назначение | Первый режим |
| --- | --- | --- | --- |
| `/gmail` | `gmail` | Gmail labels, messages, threads | `READ` |
| `/gdrive` | `gdrive` | Google Drive tree and metadata | `READ` |
| `/gdocs` | `gdocs` | Google Docs as structured JSON | `READ` |
| `/gsheets` | `gsheets` | Google Sheets as JSON / ranges | `READ` |
| `/gslides` | `gslides` | Google Slides as structured JSON | `READ` |

Первые подключения должны быть read-only. Запись в Docs, Sheets, Slides, Drive или Gmail включается только отдельным решением.

## Что уже подготовлено

- [workspace.google.template.yaml](/Users/densmirnov/Github/mirage-pos/workspace.google.template.yaml) — отдельный Mirage workspace с Google mounts.
- [config/google-workspace.sources.yaml](/Users/densmirnov/Github/mirage-pos/config/google-workspace.sources.yaml) — реестр канала и политика первого подключения.
- [.env.example](/Users/densmirnov/Github/mirage-pos/.env.example) — переменные `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_REFRESH_TOKEN`.
- [scripts/google-refresh-token.sh](/Users/densmirnov/Github/mirage-pos/scripts/google-refresh-token.sh) — обмен одноразового OAuth `code` на refresh token.

## Шаг 1. Создать Google Cloud Project

1. Открыть [Google Cloud Console](https://console.cloud.google.com/).
2. Создать новый project, например `Mirage`.
3. Выбрать этот project в project selector.

## Шаг 2. Включить API

В [API Library](https://console.cloud.google.com/apis/library) включить:

- Google Drive API;
- Google Docs API;
- Google Sheets API;
- Google Slides API;
- Gmail API.

Факт: страница Mirage setup явно называет Drive API и Docs API. Для полного набора mounts логически нужны также Sheets, Slides и Gmail API; иначе соответствующие mounts могут получить `403` при первом запросе.

## Шаг 3. Настроить OAuth consent

В Google Auth Platform:

1. Branding: app name `Mirage`, support email, developer contact email.
2. Audience: user type `External`.
3. Добавить свой Google email как test user.
4. Data Access: добавить scopes.

Минимальный практический набор для первого read-only подключения:

```text
https://www.googleapis.com/auth/drive.readonly
https://www.googleapis.com/auth/documents.readonly
https://www.googleapis.com/auth/spreadsheets.readonly
https://www.googleapis.com/auth/presentations.readonly
https://www.googleapis.com/auth/gmail.readonly
```

Если позже нужен write-back, scopes придется расширять до write/full вариантов.

Критическая деталь: если app остается в Testing, refresh token обычно живет 7 дней. Для постоянной личной синхронизации приложение нужно перевести в Production. Для личного использования предупреждение “unverified app” нормально.

## Шаг 4. Создать OAuth Client

1. Clients -> Create OAuth client.
2. Application type: `Desktop app`.
3. Скопировать Client ID и Client Secret.
4. Записать их в локальный `.env`.

```bash
cp .env.example .env
```

Заполнить:

```bash
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
GOOGLE_REFRESH_TOKEN=
```

## Шаг 5. Получить authorization code

Открыть URL, заменив `YOUR_CLIENT_ID`:

```text
https://accounts.google.com/o/oauth2/v2/auth?client_id=YOUR_CLIENT_ID&redirect_uri=http://localhost:1&response_type=code&scope=https://www.googleapis.com/auth/drive.readonly%20https://www.googleapis.com/auth/documents.readonly%20https://www.googleapis.com/auth/spreadsheets.readonly%20https://www.googleapis.com/auth/presentations.readonly%20https://www.googleapis.com/auth/gmail.readonly&access_type=offline&prompt=consent
```

После согласия браузер перейдет на `http://localhost:1?...`. Страница не откроется, это нормально. Нужно скопировать значение параметра `code` из адресной строки.

## Шаг 6. Обменять code на refresh token

После заполнения `GOOGLE_CLIENT_ID` и `GOOGLE_CLIENT_SECRET` в `.env`:

```bash
set -a && source .env && set +a
./scripts/google-refresh-token.sh 'PASTE_CODE_HERE'
```

Скрипт выведет JSON. Значение `refresh_token` перенести в `.env`:

```bash
GOOGLE_REFRESH_TOKEN=1//...
```

Если `refresh_token` не пришел:

- проверить `access_type=offline`;
- проверить `prompt=consent`;
- заново открыть auth URL и получить новый code;
- убедиться, что redirect URI везде `http://localhost:1`.

## Шаг 7. Проверить Mirage

```bash
set -a && source .env && set +a
mirage workspace create workspace.google.template.yaml --id mirage-google
mirage workspace get mirage-google
mirage execute -w mirage-google -c "ls /gdrive/"
mirage execute -w mirage-google -c "ls /gmail/"
mirage execute -w mirage-google -c "ls /gdocs/"
mirage execute -w mirage-google -c "ls /gsheets/"
mirage execute -w mirage-google -c "ls /gslides/"
```

Перед широким чтением:

```bash
mirage provision -w mirage-google -c "find /gdrive -maxdepth 2 -type f | head -50"
```

## Критическая проверка

Слабое место — scopes. Read-only scopes безопаснее, но если конкретный Mirage write-командный слой ожидает full scopes, операция записи не пройдет. Это нормальная защита на первом этапе. Расширять scopes стоит только после того, как станет ясно, какие действия агенту действительно разрешены.

Источники:

- [Mirage Google Workspace setup](https://docs.mirage.strukto.ai/home/setup/google.md)
- [Mirage Gmail resource](https://docs.mirage.strukto.ai/python/resource/gmail.md)
- [Mirage Google Drive resource](https://docs.mirage.strukto.ai/python/resource/gdrive.md)
- [Mirage Google Docs resource](https://docs.mirage.strukto.ai/python/resource/gdocs.md)
- [Mirage Google Sheets resource](https://docs.mirage.strukto.ai/python/resource/gsheets.md)
- [Mirage Google Slides resource](https://docs.mirage.strukto.ai/python/resource/gslides.md)
