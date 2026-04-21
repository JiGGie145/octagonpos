---
description: "Review plan progress, detect drift, and commit completed work for the current session"
argument-hint: "Optional notes about what was done (e.g. 'Phase 1 complete')"
agent: "agent"
---

You are in Agent/Edit mode and have permission to modify files and commit. Your task is to finalize the current work session.

Perform the following steps in order:

## 1. Locate the Active Plan

Locate the plan file that is currently being followed.

Search in this order:

1. Look for files matching: `specs/*plan.md`
2. If none are found, check session memory: `/memories/session/plan.md`

Rules:
- If multiple plan files exist in `specs/`, ask the user which plan is active before continuing.
- If no plan file is found in either location, STOP and ask the user to provide or create a plan file.
- Once found, read the entire plan file before continuing.

Read the full plan so you know what tasks exist and what their expected state is.

## 2. Review What Was Done

Examine the actual changes made this session:
- Run `git status` to see untracked and modified files
- Run `git diff --cached` and `git diff` to see changes
- Compare changed files against the plan tasks

## 3. Update Plan Progress

Mark completed steps in the plan file as done. Use `[x]` or `~~strikethrough~~` consistent with the file's existing style.

**Rules:**
- Only mark tasks that are verifiably complete based on the actual diff
- Do NOT add new tasks
- Do NOT remove or reword existing tasks
- Do NOT mark tasks as complete if they were only partially implemented

## 4. Detect Plan Drift

Check whether any of the following occurred:
- New decisions were made that affect the plan
- Scope changed (features added, removed, or redesigned)
- Implementation differs meaningfully from what the plan described
- New files were created that don't correspond to any plan task

If drift is detected, **STOP** and ask the user:

> "The implementation differs from the plan in the following ways: [list diffs]. Should I update the plan file to reflect this?"

Wait for confirmation before modifying plan structure.

## 5. Commit Changes

Stage all relevant files and create a git commit.

Commit message format:
```
<type>: <short summary>

<optional body: list completed plan steps>
```

Types: `feat`, `docs`, `refactor`, `fix`, `chore`

Use `feat` when feature code was added, `docs` for documentation/spec/planning changes, `chore` for tooling/config.

Example:
```
docs: add inventory feature plan and update copilot instructions

- Created specs/plan.md with 7-phase implementation plan
- Updated .github/copilot-instructions.md with concrete conventions
- Added inventory and reporting spec files
```

**Do not push.** Commit only.
