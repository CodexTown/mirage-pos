# Презентация решения Mirage POS

## Короткое позиционирование

Mirage POS в этой папке — это подготовленный контур для личной и рабочей файловой модели контекста. Он не заменяет исходные сервисы, а дает агенту единый слой чтения, поиска, нормализации и проверки через привычные файловые команды.

Фактическое состояние репозитория:

- локальный Mirage workspace описан в [`workspace.yaml`](../workspace.yaml);
- дерево контекста описано в [`context/README.md`](../context/README.md);
- правила синхронизации описаны в [`config/sync-manifest.yaml`](../config/sync-manifest.yaml);
- Google Workspace подготовлен как отдельный read-only шаблон в [`workspace.google.template.yaml`](../workspace.google.template.yaml);
- внешние каналы пока не подключены, потому что нужны credentials и заполненный [`channel-questionnaire.md`](channel-questionnaire.md).

## Проблема

Рабочий контекст обычно размазан по письмам, документам, репозиториям, чатам, задачам, таблицам и локальным файлам. Агенту трудно работать надежно, если каждый источник требует отдельной логики, отдельных правил доступа и отдельного формата извлечения.

Практические последствия:

1. Решения теряются в письмах и чатах.
2. Задачи живут в нескольких системах и противоречат друг другу.
3. Документы без индекса становятся невидимыми для агента.
4. Write-back во внешние системы опасен без явных правил.
5. Секреты и приватные данные легко смешать с полезным контекстом.

## Идея решения

Mirage дает виртуальное дерево файлов поверх разных ресурсов. Для агента это снижает интеграционную сложность: вместо набора отдельных API появляется файловая модель, которую можно читать командами `ls`, `find`, `cat`, `grep`, `jq`, `wc` и похожими инструментами.

В этом репозитории Mirage POS используется как управляющий контур:

- `workspace*.yaml` задают mounts и права;
- `config/*.yaml` фиксируют источники, правила и целевые артефакты;
- `context/` хранит локальные raw, extracted и summary материалы;
- `docs/` объясняет подключение, правила использования и ограничения;
- `.env` остается локальным хранилищем секретов и не должен попадать в git.

## Архитектура

```text
External sources
  Gmail / Drive / Docs / Sheets / Slides / GitHub / Slack / Telegram / Notion / databases
        |
        | read-only mounts first
        v
Mirage workspace
  /context    local writable context tree
  /docs       read-only documentation
  /config     read-only sync and source manifests
  /scratch    temporary RAM workspace
        |
        v
Normalization layer
  decisions.jsonl
  tasks.jsonl
  projects.jsonl
  people.jsonl
  daily-index.md
  project-map.md
        |
        v
Agent usage
  search, summarize, compare, verify, prepare briefings, detect conflicts
```

## Текущие компоненты

| Компонент | Файл | Статус | Назначение |
| --- | --- | --- | --- |
| Локальный workspace | [`workspace.yaml`](../workspace.yaml) | подготовлен | mounts `/context`, `/docs`, `/config`, `/scratch` |
| Google template | [`workspace.google.template.yaml`](../workspace.google.template.yaml) | подготовлен | read-only mounts `/gmail`, `/gdrive`, `/gdocs`, `/gsheets`, `/gslides` |
| Sync manifest | [`config/sync-manifest.yaml`](../config/sync-manifest.yaml) | подготовлен | локальные пути, правила, цели нормализации |
| Source template | [`config/sources.example.yaml`](../config/sources.example.yaml) | шаблон | список возможных каналов |
| Google source policy | [`config/google-workspace.sources.yaml`](../config/google-workspace.sources.yaml) | pending credentials | политика первого Google Workspace подключения |
| Context tree | [`context/`](../context/) | подготовлен | raw, profile, sources, extracted, summaries, archive |
| OAuth helper | [`scripts/google-refresh-token.sh`](../scripts/google-refresh-token.sh) | подготовлен | обмен Google authorization code на refresh token |

## Демонстрационный сценарий

### 1. Показать локальный workspace

```bash
cp .env.example .env
set -a && source .env && set +a
mirage workspace create workspace.yaml --id mirage-pos
mirage workspace get mirage-pos
```

Что демонстрируется:

- workspace создается из декларативного YAML;
- локальные docs/config доступны read-only;
- `context/` доступен как writable зона для контролируемой нормализации.

### 2. Показать файловый доступ к контексту

```bash
mirage execute -w mirage-pos -c "find /context -maxdepth 2 -type f | sort"
mirage execute -w mirage-pos -c "cat /docs/data-contract.md | head -n 40"
mirage execute -w mirage-pos -c "grep -r \"write-back\" /docs /config"
```

Что демонстрируется:

- агенту не нужен отдельный API для каждого локального раздела;
- документация, конфиги и контекст доступны через одну командную модель;
- правила безопасности можно проверять текстовым поиском.

### 3. Показать Google Workspace как следующий слой

```bash
set -a && source .env && set +a
mirage workspace create workspace.google.template.yaml --id mirage-google
mirage execute -w mirage-google -c "ls /gdrive/"
mirage execute -w mirage-google -c "ls /gmail/"
```

Условие: переменные `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` и `GOOGLE_REFRESH_TOKEN` должны быть заполнены локально. Без них этот шаг является только демонстрацией подготовленного шаблона.

### 4. Показать безопасное широкое чтение через provision

```bash
mirage provision -w mirage-google -c "find /gdrive -maxdepth 2 -type f | head -50"
```

Что демонстрируется:

- широкое чтение внешних источников выделено в отдельный режим;
- дорогое чтение не должно запускаться случайно;
- первый режим для внешних каналов остается read-only.

## Пользовательские сценарии

### Ежедневный briefing

Цель: получить краткую картину новых решений, задач, документов и рисков за день.

Поток:

1. Прочитать новые письма, документы и задачи.
2. Извлечь решения в `context/30-extracted/decisions.jsonl`.
3. Извлечь обязательства в `context/30-extracted/tasks.jsonl`.
4. Обновить `context/40-summaries/daily-index.md`.
5. Отметить конфликты и устаревшие сведения.

### Карта проектов

Цель: видеть активные проекты, источники истины, владельцев и связанные документы.

Поток:

1. Прочитать GitHub, Google Drive, документы и planning-систему.
2. Сопоставить названия проектов и aliases.
3. Обновить `context/30-extracted/projects.jsonl`.
4. Сжать результат в `context/40-summaries/project-map.md`.

### Поиск решений

Цель: быстро ответить, где и почему было принято решение.

Поток:

1. Искать по нормализованным decisions.
2. Проверять source links.
3. Если источники противоречат друг другу, сохранять статус `conflict`, а не выбирать удобную версию.

### Подготовка к write-back

Цель: включить запись только там, где понятны действие, владелец, формат и rollback.

Минимальные условия:

1. Канал явно разрешен как writable.
2. Есть подтверждение пользователя перед отправкой или правкой.
3. Записывается audit trail.
4. Есть rollback или компенсационное действие.
5. Секреты не попадают в docs, context или snapshots.

## Ценность

Для пользователя:

- меньше ручного поиска по разрозненным сервисам;
- понятная граница между raw data, extracted facts и summaries;
- единое место для правил доступа;
- возможность стартовать с read-only режима и расширять права постепенно.

Для агента:

- обычная файловая модель вместо набора несвязанных API;
- меньше скрытых предположений о каналах;
- явный data contract для статусов `raw`, `parsed`, `summarized`, `verified`, `stale`, `conflict`;
- проверяемые пути к источникам.

Для безопасности:

- внешние mounts стартуют read-only;
- write-back запрещен без отдельного решения;
- секреты остаются в `.env`;
- snapshots и summaries не должны включать credentials.

## Ограничения

Факты:

- локальная структура и Google Workspace template уже подготовлены;
- реальные внешние каналы не подключены;
- нет подтвержденной первой внешней синхронизации;
- нет production-grade политики write-back;
- нет заполненного `config/sources.local.yaml`.

Вывод:

Решение сейчас находится на стадии подготовленного workspace и операционного дизайна. Его уже можно использовать для локальной проверки и демонстрации модели, но нельзя представлять как завершенную live-синхронизацию всех каналов.

## Roadmap внедрения

### Этап 1. Локальная база

Статус: подготовлено.

Результат:

- `context/` создан;
- локальные mounts описаны;
- базовая документация и контракты есть;
- Google Workspace template подготовлен.

### Этап 2. Выбор каналов

Вход:

- заполненный [`channel-questionnaire.md`](channel-questionnaire.md);
- список источников истины;
- список запрещенных тем и каналов.

Результат:

- `config/sources.local.yaml`;
- перечень нужных env-переменных;
- список read-only mounts;
- список каналов, где write-back запрещен.

### Этап 3. Первая read-only синхронизация

Рекомендуемый порядок:

1. Google Drive / Docs / Sheets / Slides.
2. Gmail.
3. GitHub.
4. Slack / Telegram / Notion / Linear только после уточнения доступа.

### Этап 4. Нормализация

Цель:

- извлечь decisions, tasks, projects, people;
- добавить source refs;
- сохранить конфликты;
- обновить summary-файлы.

### Этап 5. Controlled write-back

Write-back включается только после отдельного решения. До этого любые внешние системы считаются read-only.

## Слайды для короткой презентации

1. **Проблема**: контекст размазан по сервисам, агент видит фрагменты.
2. **Решение**: Mirage дает файловый слой поверх источников.
3. **Текущий workspace**: `/context`, `/docs`, `/config`, `/scratch`.
4. **Google Workspace template**: Gmail, Drive, Docs, Sheets, Slides в read-only режиме.
5. **Data contract**: raw -> parsed -> summarized -> verified / stale / conflict.
6. **Безопасность**: read-only first, secrets in `.env`, write-back only by explicit approval.
7. **Demo flow**: create workspace, inspect context, search docs, prepare Google mounts.
8. **Next step**: заполнить questionnaire и создать `config/sources.local.yaml`.

## Критическая проверка

Самая слабая часть не в Mirage, а в границах доступа. Если подключить все источники сразу, система получит много шума, противоречий и приватных данных без ясной ценности. Надежный путь — начать с 2-3 read-only каналов, проверить нормализацию и только потом обсуждать write-back.
