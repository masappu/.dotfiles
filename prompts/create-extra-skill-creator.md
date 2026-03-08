# extra-skill-creator 作成プロンプト

`/Users/masa/.dotfiles` で作業してください。既存の `skill-creator` をラップする新しい Codex skill `extra-skill-creator` を実装してください。提案だけで止めず、必要なファイル作成、内容実装、検証まで進めてください。

## 最初に読むもの

- `/Users/masa/.dotfiles/.codex/skills/.system/skill-creator/SKILL.md`
- `/Users/masa/.dotfiles/.codex/skills/agent-creator/SKILL.md`
- `/Users/masa/.dotfiles/.codex/config.toml`
- `/Users/masa/.dotfiles/prompts/MULTI_AGENT_GUIDELINES.md`

## 目的

`extra-skill-creator` は、ユーザーが新しい skill を作りたいときに、まずその要求が multi-agent 向きかどうかを判定する wrapper skill にする。

- multi-agent が不要なら、既存の `skill-creator` の通常フローにフォールバックする
- multi-agent が必要なら、orchestrator / agent / skill の構成を設計し、ユーザー承認後に並列実装まで進める

## 作成対象

- skill 名: `extra-skill-creator`
- 作成先: `/Users/masa/.dotfiles/.codex/skills/extra-skill-creator`

`skill-creator` の指針に従って、必要最小限の構成で実装してください。

- `SKILL.md`
- `agents/openai.yaml`
- `references/MULTI_AGENT_GUIDELINES.md`
- 必要なら最小限の `scripts/` や `assets/`

`README.md` や補助説明書のような余計なドキュメントは作らないでください。

## 実装要件

### 1. multi-agent 指針は reference に分離する

multi-agent の実装指針と要否判断の定義は、`SKILL.md` に直接書かず、必ず `references/MULTI_AGENT_GUIDELINES.md` に分離してください。

`references/MULTI_AGENT_GUIDELINES.md` は、`/Users/masa/.dotfiles/prompts/MULTI_AGENT_GUIDELINES.md` を元に作成してください。`extra-skill-creator` で使うには不足がある場合のみ、内容を調整してから新規 reference として配置してください。

`SKILL.md` には次だけを書いてください。

- multi-agent 要否判断や multi-agent 構成設計は `references/MULTI_AGENT_GUIDELINES.md` を参照すること

`SKILL.md` に、判断基準や設計原則の詳細を重複して書かないでください。

### 2. multi-agent 要否判定

multi-agent 要否判定そのものは `references/MULTI_AGENT_GUIDELINES.md` を参照して実施するようにしてください。

### 3. multi-agent 不要時の分岐

multi-agent 不要と判断した場合は、余計な設計を増やさず、既存の `skill-creator` の通常フローをそのまま使うようにしてください。

- 必要なら「なぜ multi-agent 不要か」を短く説明する
- その後は通常の skill 作成として進める

### 4. multi-agent 必要時の分岐

multi-agent が必要と判断した場合のフローを明記してください。

1. orchestrator / agent / skill の候補構成を整理する
2. 各コンポーネントの責務、入出力、依存関係、並列実装の可否を定義する
3. 実装プランをユーザーに提示し、明示的な承認を得る
4. 承認後、並列 / 個別実行する子skill（実行agentの生成も含む）を新しい agent を起動して新規コンテキストにて実装する
   - write scope が競合しないものは並列に実装する 
5. 全ての子skillを実装後、全体進行管理するorchestratorを新しい agent を起動してskillとして実装する
6. 最終成果物をまとめて報告する

この分岐では次の制約も含めてください。

#### orchestratorの実装
- orchestratorは実行agentを持たない
- `agents.skill-creator` agent を起動して実装する

#### 子skillの実装
- 子skillごとに新規 agentを起動し、新規コンテキストで実装する
- 1つの子skillに対して1つのagent（実行器）を実装する
- 子skill内では明示的に、agent（実行器）を指定する
- 各実装 は `agents.skill-creator`を起動し、実装する
  - agent 作成タスクでは `agent-creator` skill を使う
  - skill 作成タスクでは `skill-creator` skill を使う

### 5. 最終報告

multi-agent 分岐の最終報告には、少なくとも次を含めるようにしてください。

- 各 orchestrator / agent / skill の概要
- 各 orchestrator / agent / skill の利用方法
- どの部分を並列実装したか
- 必要な follow-up があれば短く列挙する

## 期待する skill 設計

`SKILL.md` は concise に保ち、body は imperative form で書いてください。詳細化が必要なら `references/` に逃がしてください。特に以下が読み取れる構成にしてください。

- どんな依頼で `extra-skill-creator` を使うべきか
- multi-agent の詳細判断と設計方針は `references/MULTI_AGENT_GUIDELINES.md` を読むこと
- どの条件なら通常の `skill-creator` にフォールバックするか
- multi-agent 採用時の承認ゲート
- 並列実装のルール
- 完了時の報告内容

`references/MULTI_AGENT_GUIDELINES.md` には、少なくとも以下を含めてください。

- multi-agent の採用判断基準
- 一時 agent と永続 agent の使い分け
- orchestrator / agent / skill の責務分離
- 並列化の可否判断
- 実装 plan 固定と承認ゲート
- write conflict を避けるルール

## 実装手順

`skill-creator` のプロセスに従って実装してください。必要なら次を使ってください。

- `/Users/masa/.dotfiles/.codex/skills/.system/skill-creator/scripts/init_skill.py`
- `/Users/masa/.dotfiles/.codex/skills/.system/skill-creator/scripts/generate_openai_yaml.py`
- `/Users/masa/.dotfiles/.codex/skills/.system/skill-creator/scripts/quick_validate.py`

新規作成後は `quick_validate.py` で検証し、問題があれば修正してください。

## 受け入れ条件

完成した `extra-skill-creator` は、少なくとも次を満たしてください。

- frontmatter の `description` に trigger 条件が明確に入っている
- `references/MULTI_AGENT_GUIDELINES.md` が作成されている
- `SKILL.md` に multi-agent の詳細定義を重複記載しない
- まず reference を使って multi-agent 要否を判断する
- 不要なら `skill-creator` にフォールバックする
- 必要なら「構成設計 -> ユーザー承認 -> 並列実装 -> 最終報告」の順で進む
- multi-agent 時に agent / skill / orchestrator の責務分離を説明できる
- multi-agent 時に各 skill / agent を新規 `skill-creator` agent で分担実装する
- agent 作成では `agent-creator` skill、skill 作成では `skill-creator` skill を使い分ける
- `quick_validate.py` を通る

## 最終報告の仕方

作業完了後は、以下を短く報告してください。

- 作成・更新したファイル
- multi-agent 判定ロジックの要点
- `extra-skill-creator` の使い始め方
- 実行した検証
