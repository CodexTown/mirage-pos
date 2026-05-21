# Подробный гайд по использованию Mirage POS

## Назначение

Этот гайд описывает, как использовать текущий репозиторий как Mirage workspace для локального контекста и будущей синхронизации внешних каналов.

Граница фактов:

- локальный workspace уже описан в [`workspace.yaml`](../workspace.yaml);
- Google Workspace описан отдельным шаблоном [`workspace.google.template.yaml`](../workspace.google.template.yaml);
- настоящие Google credentials должны храниться только локально в `.env`;
- подключение реальных внешних источников требует заполненного [`channel-questionnaire.md`](channel-questionnaire.md) и отдельного `config/sources.local.yaml`;
- write-back во внешние системы по умолчанию запрещен.

## Быстрый старт

### 1. Перейти в папку проекта

```bash
cd /Users/densmirnov/Github/mirage-pos
```

### 2. Создать локальный `.env`

```bash
cp .env.example .env
```

Для локального workspace достаточно переменной `MIRAGE_POS_ROOT`. Если она не задана в `.env.example`, добавьте ее локально:

```bash
MIRAGE_POS_ROOT=/Users/densmirnov/Github/mirage-pos
```

Не коммитьте `.env`.

### 3. Загрузить переменные окружения

```bash
set -a && source .env && set +a
```

### 4. Создать Mirage workspace

```bash
mirage workspace create workspace.yaml --id mirage-pos
```

### 5. Проверить workspace

```bash
mirage workspace get mirage-pos
mirage execute -w mirage-pos -c "find /context -maxdepth 2 -type f | sort"
mirage execute -w mirage-pos -c "cat /docs/mirage-usage.md | head -n 30"
mirage execute -w mirage-pos -c "cat /config/sync-manifest.yaml"
```

## Локальные mounts

Текущий [`workspace.yaml`](../workspace.yaml) задает четыре mounts.

| Mount | Resource | Mode | Назначение |
| --- | --- | --- | --- |
| `/scratch` | `ram` | `WRITE` | временная рабочая зона внутри Mirage |
| `/context` | `disk` | `WRITE` | локальное дерево контекста |
| `/docs` | `disk` | `READ` | документация проекта |
| `/config` | `disk` | `READ` | sync manifests и source templates |

Практическая логика:

- агент может писать только в `/context` и `/scratch`;
- документация и конфиги в Mirage читаются как read-only;
- изменения в `docs/` и `config/` лучше делать обычными repo edits, а не через Mirage write layer.

## Структура `context/`

| Путь | Назначение |
| --- | --- |
| `context/00-inbox/` | сырые экспорты, временные материалы, ручные выгрузки |
| `context/10-profile/` | устойчивые сведения о пользователе, проектах и предпочтениях |
| `context/20-sources/` | реестр каналов, схемы, статус подключений |
| `context/30-extracted/` | нормализованные JSONL/CSV/YAML/MD извлечения |
| `context/40-summaries/` | короткие индексы и сводки для агента |
| `context/90-archive/` | устаревшие или закрытые материалы |

Правило: raw data не является verified memory. Любая сводка без ссылки на источник считается гипотезой.

## Базовые команды

### Посмотреть список файлов контекста

```bash
mirage execute -w mirage-pos -c "find /context -maxdepth 3 -type f | sort"
```

### Прочитать документацию через Mirage

```bash
mirage execute -w mirage-pos -c "cat /docs/data-contract.md"
```

### Найти упоминания write-back

```bash
mirage execute -w mirage-pos -c "grep -r \"write-back\" /docs /config /context"
```

### Посчитать объем локального контекста

```bash
mirage execute -w mirage-pos -c "find /context -type f -print | wc -l"
```

### Использовать временную RAM-зону

```bash
mirage execute -w mirage-pos -c "printf 'temporary note\n' > /scratch/note.txt && cat /scratch/note.txt"
```

## Snapshot и восстановление

### Создать snapshot

```bash
mkdir -p snapshots
mirage workspace snapshot mirage-pos snapshots/mirage-pos.tar
```

### Удалить workspace

```bash
mirage workspace delete mirage-pos
```

Удаление workspace не должно удалять исходные файлы репозитория, если resource настроен как disk mount поверх существующих локальных путей. Но перед опасными операциями лучше иметь snapshot и чистый `git status`.

## Google Workspace

Google Workspace подключается отдельным шаблоном, чтобы не смешивать локальную проверку и внешние credentials.

### Подготовленные mounts

| Mount | Resource | Mode | Что читает |
| --- | --- | --- | --- |
| `/gmail` | `gmail` | `READ` | labels, messages, threads |
| `/gdrive` | `gdrive` | `READ` | Drive tree и metadata |
| `/gdocs` | `gdocs` | `READ` | Google Docs как structured JSON |
| `/gsheets` | `gsheets` | `READ` | Google Sheets JSON и ranges |
| `/gslides` | `gslides` | `READ` | Google Slides structured JSON |

### Переменные окружения

```bash
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
GOOGLE_REFRESH_TOKEN=...
```

Эти значения должны быть только в `.env` или менеджере секретов. Не переносите их в `docs/`, `context/`, `config/`, task notes или screenshots.

### Получить refresh token

Подробные шаги описаны в [`google-workspace-setup.md`](google-workspace-setup.md). После получения authorization code:

```bash
set -a && source .env && set +a
./scripts/google-refresh-token.sh 'PASTE_CODE_HERE'
```

Затем перенесите `refresh_token` из ответа в `.env`.

### Создать Google workspace

```bash
set -a && source .env && set +a
mirage workspace create workspace.google.template.yaml --id mirage-google
mirage workspace get mirage-google
```

### Проверить mounts

```bash
mirage execute -w mirage-google -c "ls /gdrive/"
mirage execute -w mirage-google -c "ls /gmail/"
mirage execute -w mirage-google -c "ls /gdocs/"
mirage execute -w mirage-google -c "ls /gsheets/"
mirage execute -w mirage-google -c "ls /gslides/"
```

Если команда получает `403`, `401` или пустой ответ, проверяйте:

1. Включены ли нужные Google APIs.
2. Есть ли нужные read-only scopes.
3. Добавлен ли пользователь как test user, если OAuth app в Testing.
4. Не истек ли refresh token.
5. Совпадает ли `redirect_uri=http://localhost:1`.

## Когда использовать `mirage provision`

`provision` нужен перед широкими или потенциально дорогими чтениями.

Используйте `provision` для:

- рекурсивного поиска по Drive;
- больших mailbox reads;
- object storage buckets;
- logs;
- database mounts;
- больших директорий с неизвестным объемом.

Пример:

```bash
mirage provision -w mirage-google -c "find /gdrive -maxdepth 2 -type f | head -50"
```

Не используйте широкие `find`, `grep -r` и `cat` по внешним mounts без понимания объема данных.

## От questionnaire к рабочей синхронизации

Перед подключением новых каналов заполните [`channel-questionnaire.md`](channel-questionnaire.md).

Минимально нужно определить:

1. Какие 2-3 канала подключаются первыми.
2. За какой период читается история.
3. Какие folders, labels, repos или spaces входят в scope.
4. Какие темы, люди или проекты запрещены.
5. Какие каналы строго read-only.
6. Какие источники считаются источниками истины при конфликте.

После этого создается локальный файл:

```text
config/sources.local.yaml
```

Он не должен содержать secrets. В нем должны быть только channel names, mounts, scopes, modes, owners, periods и notes.

## Рекомендуемый порядок первой синхронизации

1. **Google Drive / Docs / Sheets / Slides**: структурные документы проще проверять и цитировать.
2. **Gmail**: полезен для решений и обязательств, но требует аккуратной фильтрации labels и отправителей.
3. **GitHub**: issues, PR, CI и releases дают хорошую техническую трассировку.
4. **Slack / Telegram / Discord**: подключать после явного ограничения каналов, иначе будет много шума.
5. **Notion / Linear / Trello**: подключать после решения, какая planning-система является источником истины.
6. **Databases / object storage**: только когда есть read-only policy, маскировка чувствительных данных и понятный запрос.

## Нормализация данных

Целевые файлы из [`config/sync-manifest.yaml`](../config/sync-manifest.yaml):

| Артефакт | Путь |
| --- | --- |
| Decisions | `context/30-extracted/decisions.jsonl` |
| People | `context/30-extracted/people.jsonl` |
| Projects | `context/30-extracted/projects.jsonl` |
| Tasks | `context/30-extracted/tasks.jsonl` |
| Glossary | `context/40-summaries/glossary.md` |
| Daily index | `context/40-summaries/daily-index.md` |

### Пример записи решения

```json
{"id":"decision-001","date":"2026-05-07","source":"gmail/thread-id","project":"example","decision":"Use read-only sync first.","confidence":"verified","links":["/gmail/thread-id"]}
```

### Пример записи задачи

```json
{"id":"task-001","source":"linear/ABC-123","project":"example","owner":"name","status":"open","title":"Prepare Mirage source scope.","due":null,"links":["/gdocs/doc-id"]}
```

### Обязательные поля для нормализованного факта

Каждый факт должен иметь:

1. `source`;
2. дату или диапазон;
3. статус проверки;
4. ссылку или путь;
5. краткое объяснение, почему факт важен.

## Статусы проверки

| Статус | Значение |
| --- | --- |
| `raw` | импортировано без обработки |
| `parsed` | извлечено в структуру |
| `summarized` | сжато в сводку |
| `verified` | сверено с источником |
| `stale` | устарело или требует перепроверки |
| `conflict` | противоречит другому источнику |

Запрещено превращать конфликт в один уверенный факт без проверки источников. Правильное поведение — сохранить `conflict` и указать competing sources.

## Write-back policy

По умолчанию write-back запрещен.

Нельзя делать без отдельного подтверждения:

- отправлять email;
- создавать Google Docs comments;
- менять Sheets;
- писать в Slack, Telegram или Discord;
- создавать или закрывать issues;
- обновлять Linear/Notion/Trello;
- писать в базы данных;
- удалять или перемещать файлы во внешних mounts.

Минимальные условия для write-back:

1. Канал явно разрешен как writable.
2. Описан формат действия.
3. Пользователь подтвердил конкретное действие.
4. Есть audit trail.
5. Есть rollback или компенсационное действие.
6. Проверено, что секреты и приватные данные не попадут в сообщение или документ.

## Рабочие проверки перед агентной задачей

Перед задачей на чтение или нормализацию:

```bash
git status --short
mirage workspace get mirage-pos
mirage execute -w mirage-pos -c "find /context -maxdepth 2 -type f | sort"
```

Перед задачей с Google:

```bash
set -a && source .env && set +a
mirage workspace get mirage-google
mirage execute -w mirage-google -c "ls /gdrive/"
mirage execute -w mirage-google -c "ls /gmail/"
```

Перед широким чтением:

```bash
mirage provision -w mirage-google -c "find /gdrive -maxdepth 2 -type f | head -50"
```

После нормализации:

```bash
jq -c . context/30-extracted/decisions.jsonl >/dev/null
jq -c . context/30-extracted/tasks.jsonl >/dev/null
```

Если JSONL-файл еще не создан, эта проверка не нужна. Не создавайте пустые normalized files только ради прохождения команды.

## Типовой workflow

### Локальная проверка

1. Создать `.env`.
2. Создать `mirage-pos`.
3. Проверить `/context`, `/docs`, `/config`.
4. Сделать snapshot.
5. Убедиться, что `git status` не содержит неожиданных изменений.

### Подключение первого внешнего канала

1. Заполнить questionnaire.
2. Создать `config/sources.local.yaml` без secrets.
3. Добавить нужные env-переменные в `.env`.
4. Создать отдельный workspace template или расширить существующий approved template.
5. Стартовать в `READ` mode.
6. Проверить малые команды `ls` и `head`.
7. Только потом использовать `provision`.

### Нормализация

1. Сохранить raw material или source refs.
2. Извлечь structured rows в `context/30-extracted/`.
3. Проставить statuses.
4. Сохранить conflicts.
5. Обновить summaries.
6. Проверить ссылки на источники.

## Частые ошибки

### Ошибка: попытка подключить все каналы сразу

Последствие: шум, медленные чтения, неясные права, риск утечки.

Правильное действие: начать с 2-3 read-only каналов.

### Ошибка: хранить OAuth tokens в docs или config

Последствие: секреты попадают в git, snapshots или agent context.

Правильное действие: хранить secrets только в `.env` или менеджере секретов.

### Ошибка: считать summary источником истины

Последствие: агент начинает ссылаться на пересказ вместо источника.

Правильное действие: summary должен иметь source refs; без них это hypothesis.

### Ошибка: включить write-back без rollback

Последствие: агент может отправить ошибочное сообщение или изменить задачу без восстановления.

Правильное действие: сначала описать allowed actions, confirmation rule, audit trail и rollback.

### Ошибка: широкое чтение без `provision`

Последствие: долгие операции, непредсказуемая стоимость или timeouts.

Правильное действие: использовать `mirage provision` перед большим чтением внешних mounts.

## Чеклист готовности

Локальный workspace готов, если:

- `.env` создан локально;
- `MIRAGE_POS_ROOT` указывает на repo root;
- `mirage workspace create workspace.yaml --id mirage-pos` проходит;
- `/context`, `/docs`, `/config` читаются через `mirage execute`;
- snapshot создается в `snapshots/`.

Google Workspace готов к первой проверке, если:

- Google APIs включены;
- OAuth client создан;
- read-only scopes добавлены;
- `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_REFRESH_TOKEN` заполнены локально;
- `mirage workspace create workspace.google.template.yaml --id mirage-google` проходит;
- `ls /gdrive` и `ls /gmail` проходят.

Контур готов к первой синхронизации, если:

- questionnaire заполнен;
- выбран первый набор каналов;
- создан `config/sources.local.yaml`;
- secrets не записаны в repo files;
- write-back остается disabled;
- понятны normalization targets.

## Критическая проверка

Главный риск — перепутать подготовленный workspace с уже работающей системой синхронизации. Пока внешние credentials и channel scope не зафиксированы, корректный статус: локальный контур готов, Google Workspace template готов, реальная внешняя синхронизация не подтверждена.
