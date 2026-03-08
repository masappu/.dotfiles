## 目的

この文書は、Codex における multi-agent 構成の採用判断、設計原則、実装方針、運用ルールを定義する。

multi-agent は、単一 agent で処理するよりも、
責務分離・並列実行・コンテキスト分離のメリットが明確にある場合にのみ採用する。

---

## 基本方針

Codex の multi-agent は、専門化した sub-agent を並列に起動し、
それぞれの結果を orchestrator が集約するための仕組みとして扱う。

そのため、multi-agent は以下のようなタスクに向く。

- 調査対象が複数あり、独立に探索できる
- テスト実装やレビューなど、役割ごとに分離しやすい
- 実装対象が明確に分割でき、成果物の境界が明瞭
- main context に不要な詳細を持ち込みたくない
- 並列化により所要時間または認知負荷を下げられる

一方で、以下のようなケースでは安易に multi-agent を採用しない。

- 単一 agent で十分に完結する
- 複数 agent が同じファイル群を密に編集する
- agent 間の依存関係が強く、逐次実行が中心になる
- 分割しても責務境界が曖昧
- 並列化の利益より統合コストの方が大きい

---

## 採用判断基準

multi-agent を採用するのは、以下の条件を満たす場合に限る。

### 採用してよい条件

- タスクを独立した sub task に分割できる
- 各 sub task に明確な入力と出力を定義できる
- 各担当 agent が別コンテキストで作業しても問題ない
- orchestrator が結果を集約・調停できる
- 並列実行による利得が明確である
- 実装対象ごとに write scope を分離できる
- 一時的な `spawn_agent` ではなく、永続的な sub agent を持つ再利用価値があるか、または少なくとも一時 agent の並列化価値が明確である

### 採用しない条件

- 変更対象が単一の密結合実装である
- 実装途中で頻繁な相互調整が必要である
- sub task ごとの責務が不明確である
- agent を増やしても実質的に順番待ちになる
- 生成物が 1 つだけで分業メリットが薄い
- 単一 skill と補助 script / references で十分に対応できる

### 一時 agent と永続 agent の使い分け

まず一時的な `spawn_agent` で十分かを検討する。

- 一時 agent を優先する:
  - 単発のタスク分担
  - 今回限りの調査や実装
  - 固定の権限差分や恒久的 role 定義が不要

- 永続的な sub agent を採用する:
  - 今後も繰り返し使う明確な role がある
  - モデル、sandbox、developer_instructions を role ごとに固定したい
  - agent 設定を `config.toml` と個別 config に残す価値がある

永続 agent の追加はコストが高い。再利用性が弱いなら避ける。

---

## 役割設計の原則

### 1. orchestrator を薄く保つ

orchestrator の責務は以下に限定する。

- ユーザ要求の整理
- タスク分解
- 担当 agent への依頼
- 実行順序と依存関係の管理
- 結果の集約
- 最終報告の整形

orchestrator 自身に詳細な専門知識や重い実装責務を持たせない。

### 2. agent の role は最小限にする

agent は「何を担当するか」のみを持つ。
詳細な振る舞いは agent ではなく skill に寄せる。

agent 定義には、モデル、権限、sandbox、用途のような
実行環境上の責務を中心に持たせる。

永続 agent を作る場合でも、workflow を agent config に埋め込まない。
一時 agent で十分な場合は、永続 agent を増やさずに済ませる。

### 3. 振る舞いは skill に寄せる

再利用したい手順、判断基準、作業フローは skill として定義する。

例:

- 実装計画作成
- テスト計画作成
- テスト実行
- 差分レビュー
- PR 文作成
- 調査結果の要約

skill は 1 つの仕事に集中させる。

---

## 推奨アーキテクチャ

基本構成は以下とする。

1. orchestrator
2. specialized agents
3. reusable skills

### orchestrator

- 全体進行管理
- タスクの分解
- 実行順序の決定
- 集約と最終出力

### specialized agent

- 1 agent = 1責務を原則とする
- 必要最小限の role を持つ

### skill

- 再利用可能な workflow 単位
- 明確な trigger 条件を持つ
- 入出力が明確
- 他 skill と責務が重複しない
- 実行するagentを指定する（optional）

---

## 並列実行の原則

並列化するのは、独立性の高い単位に限定する。

### 並列化に向く例

- コードベース探索
- 複数観点での調査
- テスト候補の洗い出し
- 独立したファイル群への変更
- 複数案の比較レビュー

### 並列化に向かない例

- 同一ファイルへの密な同時編集
- 前工程の出力を見ないと進められない実装
- 頻繁な仕様調整が必要な作業
- 小さすぎて分割コストの方が高い作業

---

## 実装フェーズの原則

### 1. まず plan を固定する

multi-agent 実装では、最初に以下を明確化する。

- 目的
- 成果物
- agent 構成
- skill 構成
- 入出力
- 実行順序
- 並列化可能範囲
- リスク

### 2. 承認前に実装しない

構成案と実装 plan は、必要に応じてユーザ承認を得てから進める。

### 3. 1担当 = 1コンテキスト

各 agent / skill の実装は、可能な限り新規コンテキストで実施する。
1つの担当に対して責務を混在させない。

### 4. write conflict を避ける

同じファイルや同じ責務を複数 agent で同時に扱わない。
必要なら、実装を逐次に切り替える。

---

## 命名規則

命名は責務ベースで統一する。

### agent 名

- orchestrator
- plan-executor
- test-plan-executor
- test-runner
- diff-reviewer
- pr-writer

### skill 名

- orchestrate-workflow
- plan-execute
- test-plan-execute
- run-tests
- review-diff
- write-pr

原則として、
- agent 名は「担当ロール」
- skill 名は「実行する workflow」
を表す。

---

## skill 設計ルール

各 skill は以下を満たすこと。

- 1つの job に集中している
- trigger 条件が明確
- やること / やらないことが明確
- 入力と出力が明確
- 手順が imperative に書かれている
- agent role に依存しすぎない
- 将来的に単体利用できる

---

## multi-agent 適用パターン

### 適用してよい代表例

- 実装計画、テスト計画、レビュー、PR作成を責務分離する
- 複数ディレクトリやモジュールを並列調査する
- 実装後に別 agent でテストとレビューを走らせる
- 調査・分析・比較を複数 agent に分担させる

### 適用を避ける代表例

- 1つの UIKit / SwiftUI 実装を複数 agent が同時編集する
- 仕様未確定のまま分担実装を始める
- 小規模修正を過剰に分割する
- orchestrator が実装まで抱え込む

---

## 成果物に含めるべきもの

multi-agent 構成を実装する場合、最低限以下を揃える。

- orchestrator の役割定義
- 各 agent の最小 role 定義
- 各 skill の `SKILL.md`
- 必要な config
- 実行手順
- 依存関係と運用上の注意点

---

## 最終報告の標準フォーマット

最終報告では少なくとも以下を示す。

- 構成概要
- orchestrator の責務
- 各 agent の責務
- 各 skill の責務
- 実行順序
- 並列化ポイント
- 利用方法
- 注意点

---

## 運用上の注意

- multi-agent は常に単一 agent より優れているわけではない
- 分割の目的は「複雑さの削減」であり、「構成の豪華さ」ではない
- agent を増やすほど、調停・統合・命名・責務管理が重要になる
- まずは最小構成で始め、必要に応じて分割する
- 詳細な作業手順は agent ではなく skill に寄せる

---

## この文書の適用対象

この文書は、Codex CLI / Codex app / IDE extension で
multi-agent を前提とした skill / agent / orchestrator 設計を行うときに適用する。
