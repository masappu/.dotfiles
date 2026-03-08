---
name: extra-skill-creator
description: 新しい Codex skill を作りたいという依頼に対して、それを通常の単一 skill 作成として進めるべきか、multi-agent 構成の skill 群へ拡張すべきかを判定する wrapper skill。orchestrator / 子 skill / 実行 agent への分解、明示的な agent 設計、並列実装、承認ゲートが必要になりそうな依頼で使う。multi-agent が不要な場合は既存の skill-creator フローへフォールバックする。
---

# Extra Skill Creator

## 概要

新しい skill 作成依頼について、通常の `skill-creator` フローで進めるか、multi-agent 構成へ拡張するかを判断する。multi-agent の採否、役割分離、一時 agent / 永続 agent の使い分け、承認ゲート、並列化可否、write conflict 回避は必ず `references/MULTI_AGENT_GUIDELINES.md` を参照して決める。

新規の子 skill を作る前に、まず既存で利用可能な skill を棚卸しし、要件を満たせるものがあるか確認する。既存 skill で代替できる場合は新規作成せず再利用する。

## 厳守事項
- 実装前に必ずユーザに実装プランの承認を求めること

## 実装順序

1. multi-agent 要否を判定する。
2. 既存で利用可能な skill を確認し、再利用できる責務を切り分ける。
3. 不要なら通常の `skill-creator` フローへフォールバックする。
4. 必要なら full component map を設計する。
5. ユーザーに実装 plan を提示して承認を得る。
6. 承認後、新規作成が必要な子 skill ごとに新しい `agents.skill-creator` agent を起動して新しいコンテキストで実装する。
7. 各、子 skill 実装の中で、agent 作成タスクには `agent-creator` を使い、skill 作成タスクには `skill-creator` を使う。
8. write conflict がない新規子 skill だけを並列実装する。
9. すべての子 skill 完了後に、新しい `agents.skill-creator` agent を起動して orchestrator skill を実装する。
10. 実装した skill を検証してから最終報告する。

## multi-agent の採否判断

まず `references/MULTI_AGENT_GUIDELINES.md` と `.codex/skills/skill_catalog.md` を読む。

その reference を根拠に multi-agent 要否を判定する。

multi-agent の採否にかかわらず、子 skill が必要に見える場合でも先に既存 skill の再利用可否を判定する。新規作成は再利用では不足する責務だけに限定する。

`.codex/skills/skill_catalog.md` に候補がない、または古い可能性がある場合は、`.codex/skills` と `.codex/config.toml` を確認してから判断する。

multi-agent が不要なら、理由を短く説明して既存の `skill-creator` 通常フローへそのままフォールバックする。余計な orchestrator、子 skill、agent を増やさない。

## plan 固定と承認ゲート

実装前に plan を固定してユーザーへ提示する。

plan には少なくとも次を含める。

- multi-agent を採用する理由
- orchestrator / agent / skill の一覧
- 既存 skill の再利用候補と、その採否理由
- 各コンポーネントの責務
- 各コンポーネントの入力、出力、依存関係
- 並列実装できる範囲
- 各コンポーネントの write scope
- 主なリスク

次を始める前に、明示的な承認を得る。

- 複数の子 skill 作成
- 永続 agent の追加や更新
- 並列実装の開始
- orchestrator skill の実装

承認が取れない場合は、plan を修正するか通常の `skill-creator` フローへ戻す。

## multi-agent が必要な場合

orchestrator / agent / skill の候補構成を整理する。

このとき、新規に作る子 skill と既存 skill を再利用する部分を明確に分ける。既存 skill で満たせる責務には新しい子 skill を割り当てない。

各コンポーネントの責務、入力、出力、依存関係、並列実装の可否、write scope owner を定義する。

実装 plan を固定してユーザーに提示し、明示的な承認を得る。承認前に実装しない。

## 承認後の実装

新規作成が必要な子 skill ごとに新しい agent を起動し、新しいコンテキストで実装する。

1 つの子 skill に対して 1 つの実行 agent を割り当てる。子 skill 内では実行 agent を明示する。

各実装は `agents.skill-creator` を起点に進める。

agent 作成タスクでは `agent-creator` skill を使う。

skill 作成タスクでは `skill-creator` skill を使う。

既存 skill を再利用する部分は新規実装しない。必要なら orchestrator 側の利用手順や委譲方法だけを実装対象に含める。

write scope が競合しない新規実装だけを並列化する。

すべての子 skill 実装後に、新しい `agents.skill-creator` agent を起動して orchestrator skill を実装する。

orchestrator は実行 agent を持たせない。

## 完了時の報告

最終報告には、各 orchestrator / agent / skill の概要、各利用方法、どの部分を並列実装したか、必要な follow-up を含める。
