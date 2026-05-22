# Mirage POS Context Workspace

Эта папка предназначена как локальная база контекста для будущей синхронизации через Mirage. Главная идея: собрать разные каналы в одну файловую модель, чтобы агент мог читать, искать, нормализовать и сопоставлять данные через привычные команды `ls`, `find`, `cat`, `grep`, `jq`, `wc`.

## Статус

Факты:

- `mirage` CLI установлен локально и доступен из shell.
- Mirage работает как self-hosted CLI + daemon и создает workspace из `workspace.yaml`.
- Текущая папка подготовлена как локальный ресурс, без подключения внешних аккаунтов и без секретов.

Ограничения:

- Реальные каналы не подключены, пока не заполнены ответы в [docs/channel-questionnaire.md](/Users/densmirnov/Github/mirage-pos/docs/channel-questionnaire.md).
- Секреты и OAuth-токены не должны попадать в git или публичные файлы.
- `workspace.yaml` содержит только локальный `disk` + временный `ram`; внешние mounts добавляются после выбора каналов.
- Google Workspace подготовлен отдельным шаблоном: [workspace.google.template.yaml](/Users/densmirnov/Github/mirage-pos/workspace.google.template.yaml) и [docs/google-workspace-setup.md](/Users/densmirnov/Github/mirage-pos/docs/google-workspace-setup.md).

## Структура

```text
context/
  00-inbox/       сырые выгрузки, ручные экспорты, временные файлы
  10-profile/     устойчивые сведения о пользователе, проектах, предпочтениях
  20-sources/     описания каналов, учет подключений, схемы данных
  30-extracted/   очищенные извлечения из каналов
  40-summaries/   краткие сводки и индексы для агентов
  90-archive/     устаревшие или замороженные материалы
docs/
  channel-questionnaire.md
  mirage-usage.md
  sync-plan.md
  data-contract.md
config/
  sources.example.yaml
  sync-manifest.yaml
workspace.yaml
.env.example
```

## Быстрый запуск

```bash
set -a && source .env && set +a
mirage workspace create workspace.yaml --id mirage-pos
mirage execute -w mirage-pos -c "find /context -maxdepth 2 -type f | sort"
mirage provision -w mirage-pos -c "grep -r project /context"
mirage workspace snapshot mirage-pos snapshots/mirage-pos.tar
```

Если `.env` еще не создан, для локальной проверки достаточно:

```bash
cp .env.example .env
set -a && source .env && set +a
mirage workspace create workspace.yaml --id mirage-pos
```

## Следующий практический шаг

Заполнить [опросник каналов](/Users/densmirnov/Github/mirage-pos/docs/channel-questionnaire.md). После этого можно заменить примерный `config/sources.example.yaml` на рабочий `config/sources.local.yaml` и добавить внешние mounts: Gmail, Google Drive, GitHub, Slack, Telegram, Notion, Linear, S3/R2, Postgres и другие.
