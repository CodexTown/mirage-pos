---
id: "202605221206-5AQBW3"
title: "Add Mirage setup skill and publish repo"
status: "DOING"
priority: "med"
owner: "DOCS"
revision: 10
origin:
  system: "manual"
depends_on: []
tags:
  - "docs"
verify: []
plan_approval:
  state: "approved"
  updated_at: "2026-05-22T12:07:04.566Z"
  updated_by: "ORCHESTRATOR"
  note: "User explicitly approved skill creation, commit, remote add, and push."
verification:
  state: "ok"
  updated_at: "2026-05-22T12:10:33.014Z"
  updated_by: "EVALUATOR"
  note: "EVALUATOR quality gate passed: skill frontmatter and workflow inspected; git diff --check passed; policy routing passed; ap doctor passed; push to origin/main succeeded; no real secrets were staged."
  attempts: 0
quality_review:
  state: "pass"
  updated_at: "2026-05-22T12:10:33.014Z"
  updated_by: "EVALUATOR"
  note: "EVALUATOR quality gate passed: skill frontmatter and workflow inspected; git diff --check passed; policy routing passed; ap doctor passed; push to origin/main succeeded; no real secrets were staged."
  evaluated_sha: "c3827cf73f6eb5c12494e6b8d4fd57904486e98e"
  blueprint_digest: "cec5b9055d73f6c7dce3c65c129b691910799c67df4d47c1dfbf2eec969fa56d"
  evidence_refs:
    - ".agentplane/tasks/202605221206-5AQBW3/README.md"
    - "/Users/densmirnov/Desktop/pres_mirage/mirage-pos/.agentplane/tasks/202605221206-5AQBW3/blueprint/resolved-snapshot.json"
  findings: []
commit: null
comments:
  -
    author: "DOCS"
    body: "Start: Add the repo-local Mirage setup skill and publish the mirage-pos repository after explicit user approval."
events:
  -
    type: "status"
    at: "2026-05-22T12:07:15.038Z"
    author: "DOCS"
    from: "TODO"
    to: "DOING"
    note: "Start: Add the repo-local Mirage setup skill and publish the mirage-pos repository after explicit user approval."
  -
    type: "verify"
    at: "2026-05-22T12:08:49.333Z"
    author: "DOCS"
    state: "ok"
    note: "Verified: skill frontmatter parsed; git diff --check passed; node .agentplane/policy/check-routing.mjs passed; ap doctor passed; ignored files exclude .env, snapshots, caches; secret scan found only documented placeholder examples, no real secret values."
  -
    type: "verify"
    at: "2026-05-22T12:10:33.014Z"
    author: "EVALUATOR"
    state: "ok"
    note: "EVALUATOR quality gate passed: skill frontmatter and workflow inspected; git diff --check passed; policy routing passed; ap doctor passed; push to origin/main succeeded; no real secrets were staged."
doc_version: 3
doc_updated_at: "2026-05-22T12:10:33.034Z"
doc_updated_by: "DOCS"
description: "Create a repo-local Codex skill for agent-led Mirage setup, verify the documentation-only changes, commit the mirage-pos repository, add the GitHub origin, and push main."
sections:
  Summary: "Create a repository-local Codex skill that guides agents through safe Mirage workspace setup and publish the mirage-pos repository to GitHub. Success means the skill exists, repo checks pass, only safe non-secret artifacts are committed, origin is set to CodexTown/mirage-pos, and main is pushed."
  Scope: "In scope: skills/setup-mirage/**, any minimal supporting docs or config needed for skill discovery, task docs, git remote origin, commit and push of the mirage-pos repository. Out of scope: real credentials, global Codex skill installation, changing Mirage runtime code, changing external service settings, committing .env, snapshots, caches, or secrets."
  Plan: |-
    1. Activate DOCS role.
    2. Create skills/setup-mirage/SKILL.md with concise trigger metadata and an agent-led setup workflow.
    3. Include safety gates for .env/secrets, read-only first, channel questionnaire, provision before broad reads, snapshot, and verification.
    4. Run docs checks: git diff --check, node .agentplane/policy/check-routing.mjs, ap doctor, and targeted file inspection.
    5. Stage safe repo artifacts only, commit intentionally, add origin https://github.com/CodexTown/mirage-pos.git, and push main.
  Verify Steps: |-
    1. Inspect skills/setup-mirage/SKILL.md for valid YAML frontmatter and concrete workflow instructions.
    2. Run git diff --check.
    3. Run node .agentplane/policy/check-routing.mjs.
    4. Run ap doctor.
    5. Verify git status excludes .env, snapshots/*.tar, cache files, and other secrets.
    6. Verify git remote -v shows origin=https://github.com/CodexTown/mirage-pos.git after remote setup and git push succeeds.
  Verification: |-
    <!-- BEGIN VERIFICATION RESULTS -->
    ### 2026-05-22T12:08:49.333Z — VERIFY — ok

    By: DOCS

    Note: Verified: skill frontmatter parsed; git diff --check passed; node .agentplane/policy/check-routing.mjs passed; ap doctor passed; ignored files exclude .env, snapshots, caches; secret scan found only documented placeholder examples, no real secret values.
    Attempts: 0

    VerifyStepsRef: doc_version=3, doc_updated_at=2026-05-22T12:07:15.038Z, excerpt_hash=sha256:098a5282bdae9950156b42c76f98d03ee1b3fb31655d876f54c03245a1a2af95

    Details:

    BlueprintSnapshotRef:
    - state: current
    - path: /Users/densmirnov/Desktop/pres_mirage/mirage-pos/.agentplane/tasks/202605221206-5AQBW3/blueprint/resolved-snapshot.json
    - old_digest: cec5b9055d73f6c7dce3c65c129b691910799c67df4d47c1dfbf2eec969fa56d
    - current_digest: cec5b9055d73f6c7dce3c65c129b691910799c67df4d47c1dfbf2eec969fa56d
    - route_changed: no
    - safe_command: agentplane blueprint snapshot 202605221206-5AQBW3

    ### 2026-05-22T12:10:33.014Z — VERIFY — ok

    By: EVALUATOR

    Note: EVALUATOR quality gate passed: skill frontmatter and workflow inspected; git diff --check passed; policy routing passed; ap doctor passed; push to origin/main succeeded; no real secrets were staged.
    Attempts: 0

    VerifyStepsRef: doc_version=3, doc_updated_at=2026-05-22T12:10:16.413Z, excerpt_hash=sha256:098a5282bdae9950156b42c76f98d03ee1b3fb31655d876f54c03245a1a2af95

    Details:

    BlueprintSnapshotRef:
    - state: current
    - path: /Users/densmirnov/Desktop/pres_mirage/mirage-pos/.agentplane/tasks/202605221206-5AQBW3/blueprint/resolved-snapshot.json
    - old_digest: cec5b9055d73f6c7dce3c65c129b691910799c67df4d47c1dfbf2eec969fa56d
    - current_digest: cec5b9055d73f6c7dce3c65c129b691910799c67df4d47c1dfbf2eec969fa56d
    - route_changed: no
    - safe_command: agentplane blueprint snapshot 202605221206-5AQBW3

    <!-- END VERIFICATION RESULTS -->
  Rollback Plan: |-
    - Revert task-related commit(s).
    - Re-run required checks to confirm rollback safety.
  Findings: |-
    Command: git diff --check
    Result: pass
    Evidence: no whitespace or diff hygiene errors.
    Scope: staged mirage-pos docs, config, context, and skill files.

    Command: node .agentplane/policy/check-routing.mjs
    Result: pass
    Evidence: policy routing OK.
    Scope: repository policy routing.

    Command: ap doctor
    Result: pass
    Evidence: doctor OK with errors=0 warnings=0.
    Scope: AgentPlane runtime health.

    Command: git push -u origin main
    Result: pass
    Evidence: new branch main pushed to https://github.com/CodexTown/mirage-pos.git and set to track origin/main.
    Scope: mirage-pos repository only.

    Residual note: secret scan matched only documented placeholders/examples such as GOOGLE_REFRESH_TOKEN=... and no real secret values were found.
id_source: "generated"
---
## Summary

Create a repository-local Codex skill that guides agents through safe Mirage workspace setup and publish the mirage-pos repository to GitHub. Success means the skill exists, repo checks pass, only safe non-secret artifacts are committed, origin is set to CodexTown/mirage-pos, and main is pushed.

## Scope

In scope: skills/setup-mirage/**, any minimal supporting docs or config needed for skill discovery, task docs, git remote origin, commit and push of the mirage-pos repository. Out of scope: real credentials, global Codex skill installation, changing Mirage runtime code, changing external service settings, committing .env, snapshots, caches, or secrets.

## Plan

1. Activate DOCS role.
2. Create skills/setup-mirage/SKILL.md with concise trigger metadata and an agent-led setup workflow.
3. Include safety gates for .env/secrets, read-only first, channel questionnaire, provision before broad reads, snapshot, and verification.
4. Run docs checks: git diff --check, node .agentplane/policy/check-routing.mjs, ap doctor, and targeted file inspection.
5. Stage safe repo artifacts only, commit intentionally, add origin https://github.com/CodexTown/mirage-pos.git, and push main.

## Verify Steps

1. Inspect skills/setup-mirage/SKILL.md for valid YAML frontmatter and concrete workflow instructions.
2. Run git diff --check.
3. Run node .agentplane/policy/check-routing.mjs.
4. Run ap doctor.
5. Verify git status excludes .env, snapshots/*.tar, cache files, and other secrets.
6. Verify git remote -v shows origin=https://github.com/CodexTown/mirage-pos.git after remote setup and git push succeeds.

## Verification

<!-- BEGIN VERIFICATION RESULTS -->
### 2026-05-22T12:08:49.333Z — VERIFY — ok

By: DOCS

Note: Verified: skill frontmatter parsed; git diff --check passed; node .agentplane/policy/check-routing.mjs passed; ap doctor passed; ignored files exclude .env, snapshots, caches; secret scan found only documented placeholder examples, no real secret values.
Attempts: 0

VerifyStepsRef: doc_version=3, doc_updated_at=2026-05-22T12:07:15.038Z, excerpt_hash=sha256:098a5282bdae9950156b42c76f98d03ee1b3fb31655d876f54c03245a1a2af95

Details:

BlueprintSnapshotRef:
- state: current
- path: /Users/densmirnov/Desktop/pres_mirage/mirage-pos/.agentplane/tasks/202605221206-5AQBW3/blueprint/resolved-snapshot.json
- old_digest: cec5b9055d73f6c7dce3c65c129b691910799c67df4d47c1dfbf2eec969fa56d
- current_digest: cec5b9055d73f6c7dce3c65c129b691910799c67df4d47c1dfbf2eec969fa56d
- route_changed: no
- safe_command: agentplane blueprint snapshot 202605221206-5AQBW3

### 2026-05-22T12:10:33.014Z — VERIFY — ok

By: EVALUATOR

Note: EVALUATOR quality gate passed: skill frontmatter and workflow inspected; git diff --check passed; policy routing passed; ap doctor passed; push to origin/main succeeded; no real secrets were staged.
Attempts: 0

VerifyStepsRef: doc_version=3, doc_updated_at=2026-05-22T12:10:16.413Z, excerpt_hash=sha256:098a5282bdae9950156b42c76f98d03ee1b3fb31655d876f54c03245a1a2af95

Details:

BlueprintSnapshotRef:
- state: current
- path: /Users/densmirnov/Desktop/pres_mirage/mirage-pos/.agentplane/tasks/202605221206-5AQBW3/blueprint/resolved-snapshot.json
- old_digest: cec5b9055d73f6c7dce3c65c129b691910799c67df4d47c1dfbf2eec969fa56d
- current_digest: cec5b9055d73f6c7dce3c65c129b691910799c67df4d47c1dfbf2eec969fa56d
- route_changed: no
- safe_command: agentplane blueprint snapshot 202605221206-5AQBW3

<!-- END VERIFICATION RESULTS -->

## Rollback Plan

- Revert task-related commit(s).
- Re-run required checks to confirm rollback safety.

## Findings

Command: git diff --check
Result: pass
Evidence: no whitespace or diff hygiene errors.
Scope: staged mirage-pos docs, config, context, and skill files.

Command: node .agentplane/policy/check-routing.mjs
Result: pass
Evidence: policy routing OK.
Scope: repository policy routing.

Command: ap doctor
Result: pass
Evidence: doctor OK with errors=0 warnings=0.
Scope: AgentPlane runtime health.

Command: git push -u origin main
Result: pass
Evidence: new branch main pushed to https://github.com/CodexTown/mirage-pos.git and set to track origin/main.
Scope: mirage-pos repository only.

Residual note: secret scan matched only documented placeholders/examples such as GOOGLE_REFRESH_TOKEN=... and no real secret values were found.
