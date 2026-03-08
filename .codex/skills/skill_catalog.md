# Skill Catalog

このカタログは、ローカルで確認できた skill と対応 agent を整理したもの。新規 skill の作成時に参照し、通常のセッションでも利用できる既存 skill がないかを判断するために使う。

確認元:

- `.codex/skills/**/SKILL.md`
- `.codex/config.toml`
- `.codex/agents/**`

## 使い方

- 新規 skill の作成時に参照し、既存 skill で代替できる責務があれば再利用を優先する。
- 通常のセッションで利用できる skill がないかを判断する。
- sub agent で実行する必要がある場合は、対応する agent が定義されているか確認する。
- カタログにない skill を使う必要がある場合は、実ファイルと config を確認してから追記する。

## Skill 一覧

| skill名 | skillの概要 | skillの利用用途 | skillに対応するagent(optional) |
| --- | --- | --- | --- |
| `agent-creator` | Codex CLI の sub agent 設定を追加・更新する skill。agent 定義は最小限に保ち、詳細は config file に分離する。 | 新しい sub agent の追加、既存 agent 設定の更新、`~/.codex/config.toml` と `~/.codex/agents/<agent-name>.toml` の整備。 | `agents.agent-creator` |
| `extra-skill-creator` | 新しい skill 作成依頼を、単一 skill と multi-agent 構成のどちらで進めるか判定する wrapper skill。既存 skill の再利用を優先する。 | orchestrator / 子 skill / 実行 agent への分解判断、承認ゲート付きの multi-agent 設計、既存 skill の再利用判定。 | - |
| `skill-creator` | Codex skill を作成・更新するための基本ガイド。`SKILL.md`、references、scripts、assets の設計方針を定義する。 | 新規 skill の作成、既存 skill の更新、skill 構成の整理、agent metadata との整合維持。 | `agents.skill-creator` |
| `skill-installer` | curated list または GitHub repo/path から skill をインストールする system skill。 | install 可能な skill の一覧表示、curated skill の導入、外部 repo からの skill 取り込み。 | - |
| `slides` | `artifacts` tool を使ってプレゼン資料を作成・編集する system skill。 | スライド deck の作成、編集、render、import、export。 | - |
| `spreadsheets` | `artifacts` tool を使ってスプレッドシートを作成・編集する system skill。 | ワークブックの作成、編集、再計算、import、export。 | - |
