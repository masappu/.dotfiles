---
name: agent-creator
description: Codex CLI の multi-agent 構成で、新しい sub agent を追加するときに使う。ユーザー要件から role を決め、`~/.codex/config.toml` と `~/.codex/agents/<agent-name>.toml` を安全に作成・更新する。
---

# Agent Creator

Codex CLI の公式設定形式に従って、sub agent を追加するための手順。

sub agent は **特定の責務を持つ実行環境**として定義する。  
agent の振る舞いは可能な限り **skill 側に分離**し、agent config には最小限の設定のみを記述する。

---

# この skill を使う条件

以下の状況で使用する。

- ユーザーが「新しい sub agent を追加したい」と依頼している
- `~/.codex/config.toml` に `agents.<name>` を追加する必要がある
- role ごとの設定を `config_file` で分離したい
- agent 設定を `~/.codex/agents` 配下に整理したい

---

# 入力要件

不足があれば、まずこれを確定する。

- `agent_name`  
  追加する agent 名（`kebab-case` 推奨）

- `role_summary`  
  agent の責務を **1文で表した要約**

- `task_type`  
  `read-only` または `workspace-write`

- `model`  
  使用するモデル

- `model_reasoning_effort`  
  推論強度

---

# 実装ルール

## 言語ルール

- `agents.<name>.description` は **日本語**で記述する
- `developer_instructions` は **日本語**で記述する
- 設定キー、model 名、path などを除き、英語の定型文をそのまま使わない

## agent 定義

- `~/.codex/config.toml` の agent 定義は **最小限にする**
- `agents.<name>.description` は **役割識別に必要な最小文のみ**を **日本語**で書く
- agent の詳細設定は **必ず `config_file` に分離する**
- agent config は `~/.codex/agents/<agent-name>/` に配置する

---

## agent config の設計原則

agent config は「詳細設定を書く場所」ではあるが  
**何でも書く場所ではない**

原則:

- parent config で安全に継承できる設定は **重複定義しない**
- agent 固有の差分だけを定義する
- 再利用性を優先する
- 1 agent = 1責務 を守る

---

# `agents/<agent-name>.toml` 各項目の実装指針

## model

### 目的

agent の責務に対して  
**必要十分な推論能力・速度・コストのバランス**を与える。

### 決定ルール

- 設計 / 計画 / レビュー / 分析 → **高性能モデル**
- 実装 → **中〜高性能**
- 実行 / 整形 / 要約 → **低コストモデル**

### 推奨目安

| agent種別 | model方針 |
|---|---|
| orchestrator | 中 |
| planner | 高 |
| implementer | 中〜高 |
| reviewer | 高 |
| runner | 低 |
| writer | 低 |

### 禁止事項

- 全 agent を同じ model にしない
- reviewer / planner の model を過度に下げない
- 整形専用 agent に高性能 model を割り当てない

---

## model_reasoning_effort

### 目的

agent の **思考深度（推論量）**を制御する。

### 決定ルール

難しさではなく  
**判断密度**で決める。

判断密度とは

- 分岐判断
- 整合性確認
- 曖昧性解消
- 複数案比較

などの回数と重要度。

### 推奨マッピング

| effort | 用途 |
|---|---|
| low | 実行 / 整形 / 転記 |
| medium | 軽い実装 / 軽い調査 |
| high | 実装 / 原因調査 |
| xhigh | 設計 / 計画 / レビュー |

### 推奨既定値

| agent | reasoning |
|---|---|
| planner | xhigh |
| reviewer | xhigh |
| implementer | high |
| orchestrator | medium |
| runner | low |
| writer | low |

### 禁止事項

- 全 agent に `xhigh` を設定しない
- runner / writer に高 reasoning を設定しない
- reasoning を skill の不足の代替にしない

---

## sandbox_mode

### 目的

agent に **必要最小限の権限**のみを与える。

### 決定ルール

まず **read-only を検討する**

書き込みが必要な場合のみ  
`workspace-write` を許可する。

### 既定方針

| agent | sandbox |
|---|---|
| planner | read-only |
| reviewer | read-only |
| orchestrator | read-only |
| implementer | workspace-write |
| test-implementer | workspace-write |
| runner | read-only または workspace-write |

### 原則

- review / plan 系 agent に書き込み権限を付けない
- 将来の可能性のために権限を広げない
- 権限不足が判明した場合のみ拡張する

---

## developer_instructions

### 目的

agent に **常に適用したい固定ルール**を定義する。

これは developer message として  
すべての実行に注入される。

### 書くべき内容

- agent の恒久的責務
- 常設の禁止事項
- 短い判断ガードレール
- 日本語での簡潔な指示

### 書くべきでない内容

- workflow
- 詳細な手順
- acceptance criteria
- 実装方法
- 一時的な指示

これらは **skill 側に記述する**

### 記述ルール

- 3〜8行程度
- 最小限
- skill と重複させない
- 日本語で記述する

### 良い例

```toml
developer_instructions = """
あなたは差分レビューを行う agent です。
提示された変更だけを確認してください。
リポジトリのファイルを変更しないでください。
正しさと不足しているテストを重視してください。
"""
```

### 悪い例

```toml
developer_instructions = """
1. Read ticket
2. Plan implementation
3. Implement code
4. Run tests
5. Create PR
"""
```

これは workflow を agent に埋め込んでいるため不適切。

---

# skill と agent の責務分離

以下を厳密に守る。

| 構成 | 役割 |
|---|---|
| agent | 実行環境 |
| skill | 再利用可能な作業手順 |
| prompt | 今回の依頼内容 |

agent に workflow を書かない。

---

# 作業手順

## 1. 要件の解釈

依頼内容から

- agent の責務を **1つに絞る**

`description` は

- 最小文
- 役割識別のみ
- 日本語で記述する

---

## 2. 既存 config の確認

確認する項目

- `~/.codex/config.toml`
- `[features]`
- `[agents]`

チェック内容

- `multi_agent = true`
- 同名 agent の存在

---

## 3. `~/.codex/config.toml` 更新

未設定なら

```
[features]
multi_agent = true
```

agent 定義追加

```
[agents.<agent-name>]
description = "<日本語の簡潔な役割説明>"
config_file = "agents/<agent-name>/<agent-name>.toml"
```

---

## 4. agent config 作成

```
~/.codex/agents/<agent-name>/<agent-name>.toml
```

必須項目

```
model
model_reasoning_effort
```

必要時のみ

```
sandbox_mode
developer_instructions
```

---

## 5. 整合性確認

確認事項

- `config_file` のパス
- agent 名とディレクトリ名
- 権限設定
- model / reasoning の整合性

---

## 6. 利用方法の案内

ユーザーに次を説明する。

- 追加された agent 名
- 役割
- 使用する skill
- 呼び出し例

---

# 生成テンプレート

## `~/.codex/config.toml`

```toml
[agents.<agent-name>]
description = "<日本語の簡潔な役割説明>"
config_file = "agents/<agent-name>/<agent-name>.toml"
```

---

## `~/.codex/agents/<agent-name>/<agent-name>.toml`

```toml
model = "<required-model>"
model_reasoning_effort = "<low|medium|high|xhigh>"
```

---

### 読み取り専用 agent

```toml
sandbox_mode = "read-only"
```

---

### 書き込みが必要な agent

```toml
sandbox_mode = "workspace-write"
```

---

### 固定ルールが必要な場合のみ

```toml
developer_instructions = """
日本語の短い恒久ルール
"""
```

---
