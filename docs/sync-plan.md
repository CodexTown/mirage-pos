# План будущей синхронизации

## Цель

Собрать личный и рабочий контекст в файловую модель, где каждый канал имеет понятные права, период охвата, формат извлечения и статус проверки.

## Этап 1. Локальная база

Статус: подготовлено.

1. Создать дерево `context/`.
2. Создать `workspace.yaml` с `disk` и `ram`.
3. Создать `config/sync-manifest.yaml`.
4. Создать опросник каналов.
5. Проверить Mirage CLI на локальном mount.

## Этап 2. Выбор каналов

Вход: заполненный [channel-questionnaire.md](/Users/densmirnov/Github/mirage-pos/docs/channel-questionnaire.md).

Результат:

- `config/sources.local.yaml`;
- перечень env-переменных;
- список read-only mounts;
- список каналов, где write-back запрещен;
- приоритет первой синхронизации.

## Этап 3. Первая read-only синхронизация

Рекомендуемый порядок:

1. GitHub: репозитории, PR, issues, CI.
2. Google Workspace: Drive, Docs, Sheets, Slides, Gmail.
3. Gmail/Email outside Google: письма и решения.
4. Slack/Telegram: рабочие обсуждения.
5. Linear/Notion: задачи и планы.

Логика: сначала подключать источники с высокой структурностью и низким риском записи.

## Этап 4. Нормализация

Целевые файлы:

- `context/30-extracted/decisions.jsonl`;
- `context/30-extracted/tasks.jsonl`;
- `context/30-extracted/projects.jsonl`;
- `context/30-extracted/people.jsonl`;
- `context/40-summaries/daily-index.md`;
- `context/40-summaries/project-map.md`.

## Этап 5. Write-back

Write-back включается только после отдельного решения.

Минимальные условия:

- канал выбран как writable;
- формат записи определен;
- есть подтверждение перед отправкой;
- есть аудит изменений;
- есть rollback или компенсационное действие.

## Риски

1. Слишком широкий доступ даст шум вместо контекста.
2. Write-back без правил приведет к ошибочным сообщениям, задачам или правкам.
3. Разные каналы будут противоречить друг другу.
4. Секреты могут попасть в текстовые файлы, если смешивать `.env` и документацию.
5. Большие remote mounts могут быть дорогими или медленными без `provision`.

## Критерий готовности

Папка считается готовой к реальной синхронизации, когда:

- заполнен опросник;
- выбран первый набор каналов;
- создан локальный файл `config/sources.local.yaml`;
- `.env` содержит только нужные секреты;
- `mirage workspace create workspace.yaml --id mirage-pos` проходит без ошибок;
- `mirage provision` используется перед крупными чтениями.
