---
name: setup-mirage
description: Use when an agent needs to configure this mirage-pos repository as a Mirage workspace, select context channels, prepare safe read-only mounts, validate credentials boundaries, run Mirage CLI smoke checks, or guide a user through Google Workspace, email, GitHub, Telegram, Postgres, Redis, or local disk setup without exposing secrets.
---

# Setup Mirage

Use this skill inside the `mirage-pos` repository. Its job is to help an agent configure Mirage safely and incrementally, not to connect every channel at once.

## Operating Rules

- Keep all generated configuration in this repository.
- Never write real secrets into tracked files, task notes, screenshots, docs, or `context/`.
- Treat `.env` as local-only. Use `.env.example` only for variable names.
- Start external mounts as `READ` unless the user explicitly approves write-back scope.
- Use `mirage provision` before broad or potentially expensive reads.
- Preserve the distinction between raw data, extracted facts, summaries, and verified memory.
- If a channel requires credentials that are not present, stop with exact missing variables and next setup steps.

## Preflight

Run from repository root:

```bash
pwd
git status --short --untracked-files=no
command -v mirage
test -f workspace.yaml
test -f .env.example
```

If `.env` is missing:

```bash
cp .env.example .env
```

Then ask the user to fill only the variables needed for the selected channel. Do not invent or request unnecessary credentials.

Load local env for shell sessions:

```bash
set -a && source .env && set +a
```

## Channel Selection

Before editing channel config, inspect:

```bash
sed -n '1,220p' docs/channel-questionnaire.md
sed -n '1,220p' config/sources.example.yaml
sed -n '1,220p' config/sync-manifest.yaml
```

Ask for or infer only these fields:

- channel name;
- first useful scope: folders, labels, repos, chats, tables, schemas, or key prefixes;
- period to read first;
- `READ` versus approved write-back;
- forbidden topics, people, folders, repos, chats, tables, or environments;
- source of truth when channels conflict.

Create or update `config/sources.local.yaml` only after the scope is known. This file must not contain secrets.

## Local Workspace Smoke

Use this as the first safe check:

```bash
set -a && source .env && set +a
mirage workspace create workspace.yaml --id mirage-pos
mirage workspace get mirage-pos
mirage execute -w mirage-pos -c "find /context -maxdepth 2 -type f | sort"
mirage execute -w mirage-pos -c "cat /docs/data-contract.md | head -n 40"
mirage execute -w mirage-pos -c "grep -r \"write-back\" /docs /config /context"
```

Expected model:

- `/context` is writable local context;
- `/docs` is read-only project guidance;
- `/config` is read-only source and sync policy;
- `/scratch` is temporary RAM workspace.

## Google Workspace Setup

Use Google first when the user wants Gmail, Drive, Docs, Sheets, or Slides.

Required local variables:

```text
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
GOOGLE_REFRESH_TOKEN
```

Read:

```bash
sed -n '1,260p' docs/google-workspace-setup.md
sed -n '1,220p' workspace.google.template.yaml
```

Create and smoke-test:

```bash
set -a && source .env && set +a
mirage workspace create workspace.google.template.yaml --id mirage-google
mirage workspace get mirage-google
mirage execute -w mirage-google -c "ls /gdrive/"
mirage execute -w mirage-google -c "ls /gmail/"
```

Before recursive Drive or mailbox reads:

```bash
mirage provision -w mirage-google -c "find /gdrive -maxdepth 2 -type f | head -50"
```

If OAuth is incomplete, return the exact missing variable and point to `docs/google-workspace-setup.md`.

## Other Channels

For GitHub, Telegram, Slack, email, Postgres, Redis, object storage, and planning tools:

1. Fill the relevant section in `docs/channel-questionnaire.md`.
2. Add a secret name to `.env.example` only if the variable name is missing.
3. Put real values only in local `.env`.
4. Add non-secret scope and policy to `config/sources.local.yaml`.
5. Keep first mount read-only.
6. Run a narrow smoke command before wide reads.

Database rules:

- use read-only credentials where possible;
- never point first sync at production without explicit user approval;
- limit schemas, tables, collections, keys, or prefixes before connecting;
- mask or exclude PII before writing extracted summaries.

Messaging rules:

- scope by chat, channel, folder, label, or sender before reading;
- do not ingest private channels or DMs unless explicitly approved;
- treat attachments as a separate decision.

## Normalization

Use `config/sync-manifest.yaml` as the target map:

- decisions: `context/30-extracted/decisions.jsonl`
- tasks: `context/30-extracted/tasks.jsonl`
- projects: `context/30-extracted/projects.jsonl`
- people: `context/30-extracted/people.jsonl`
- glossary: `context/40-summaries/glossary.md`
- daily index: `context/40-summaries/daily-index.md`

Every normalized fact must include source, date or range, verification status, and a path or link. If sources conflict, preserve `conflict` instead of choosing a convenient version.

## Snapshot And Verification

After a useful setup state:

```bash
mkdir -p snapshots
mirage workspace snapshot mirage-pos snapshots/mirage-pos.tar
```

Before handing off:

```bash
git status --short
grep -R "GOOGLE_REFRESH_TOKEN=\\|_TOKEN=.*[A-Za-z0-9]\\|PASSWORD=.*[A-Za-z0-9]\\|SECRET=.*[A-Za-z0-9]" . --exclude-dir=.git --exclude=.env || true
```

Report:

- workspace ID;
- mounts configured;
- commands that passed;
- missing credentials or blocked channels;
- files changed;
- whether any data was written under `context/`;
- next safest channel to connect.
