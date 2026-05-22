# Использование Mirage в этой папке

## Что дает Mirage

Факт: Mirage представляет разные сервисы как единое виртуальное дерево файлов. Агент может использовать обычные команды: `ls`, `find`, `cat`, `grep`, `head`, `wc`, `jq`, `cp`, `mkdir`, `tee`.

Вывод: для личного контекста это полезно как единый слой над Gmail, Drive, GitHub, Slack, Telegram, Notion, S3/R2, базами данных и локальными файлами.

Гипотеза: эта папка должна стать не финальным хранилищем всего сырья, а управляющим контуром: конфиги, индексы, нормализованные извлечения, snapshots и документация.

## Локальный workspace

Текущий [workspace.yaml](/Users/densmirnov/Github/mirage-pos/workspace.yaml) создает mounts:

| Mount | Тип | Права | Назначение |
| --- | --- | --- | --- |
| `/scratch` | ram | write | временные операции внутри Mirage |
| `/context` | disk | write | локальное дерево контекста |
| `/docs` | disk | read | документация |
| `/config` | disk | read | манифесты и шаблоны |

## Команды

```bash
cp .env.example .env
set -a && source .env && set +a
mirage workspace create workspace.yaml --id mirage-pos
mirage workspace get mirage-pos
mirage execute -w mirage-pos -c "tree /context"
mirage execute -w mirage-pos -c "cat /docs/channel-questionnaire.md | head -n 20"
mirage provision -w mirage-pos -c "grep -r GitHub /context /docs /config"
mirage workspace snapshot mirage-pos snapshots/mirage-pos.tar
mirage workspace delete mirage-pos
```

## Когда использовать `provision`

`mirage provision` нужен перед дорогим чтением:

- большие buckets;
- большие mailbox exports;
- крупные logs;
- database mounts;
- recursive `grep` по внешним сервисам.

## Когда не использовать write-back

Не включать запись в каналы, пока не описаны:

- допустимые действия;
- владелец канала;
- формат изменения;
- правило rollback;
- подтверждение пользователя.

## Источники

- [strukto-ai/mirage](https://github.com/strukto-ai/mirage)
- [Mirage CLI docs](https://docs.mirage.strukto.ai/home/cli.md)
- [Mirage Resource Matrix](https://docs.mirage.strukto.ai/home/resource-matrix.md)
