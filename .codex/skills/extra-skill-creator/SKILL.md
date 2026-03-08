---
name: extra-skill-creator
description: 新しい Codex skill を作りたいという依頼に対して、それを通常の単一 skill 作成として進めるべきか、multi-agent 構成の skill 群へ拡張すべきかを判定する wrapper skill。orchestrator / 子 skill / 実行 agent への分解、明示的な agent 設計、並列実装、承認ゲートが必要になりそうな依頼で使う。multi-agent が不要な場合は既存の skill-creator フローへフォールバックする。
---

# Extra Skill Creator

## 概要

新しい skill 作成依頼について、通常の `skill-creator` フローで進めるか、multi-agent 構成へ拡張するかを判断する。multi-agent の採否、役割分離、一時 agent / 永続 agent の使い分け、承認ゲート、並列化可否、write conflict 回避は必ず `references/MULTI_AGENT_GUIDELINES.md` を参照して決める。

## 進め方

まず `references/MULTI_AGENT_GUIDELINES.md` を読む。

その reference を根拠に multi-agent 要否を判定する。

multi-agent が不要なら、理由を短く説明して既存の `skill-creator` 通常フローへそのままフォールバックする。余計な orchestrator、子 skill、agent を増やさない。

## multi-agent が必要な場合

orchestrator / agent / skill の候補構成を整理する。

各コンポーネントの責務、入力、出力、依存関係、並列実装の可否、write scope owner を定義する。

実装 plan を固定してユーザーに提示し、明示的な承認を得る。承認前に実装しない。

## 承認後の実装

子 skill ごとに新しい agent を起動し、新しいコンテキストで実装する。

1 つの子 skill に対して 1 つの実行 agent を割り当てる。子 skill 内では実行 agent を明示する。

各実装は `agents.skill-creator` を起点に進める。

agent 作成タスクでは `agent-creator` skill を使う。

skill 作成タスクでは `skill-creator` skill を使う。

write scope が競合しない実装だけを並列化する。

すべての子 skill 実装後に、新しい `agents.skill-creator` agent を起動して orchestrator skill を実装する。

orchestrator は実行 agent を持たせない。

## 完了時の報告

最終報告には、各 orchestrator / agent / skill の概要、各利用方法、どの部分を並列実装したか、必要な follow-up を含める。
