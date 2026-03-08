# Multi-Agent Guidelines

## 目的

新しい skill 作成依頼に対して、multi-agent を採用するべきか、通常の単一 skill 作成に留めるべきかを判断するための基準を定義する。

この判断では「分割できるか」ではなく、「multi-agent にすると再利用性、責務分離、並列実装、コンテキスト分離の利得が本当に増えるか」を見る。

## multi-agent を採用する条件

次をすべて満たす場合に限って multi-agent を採用する。

- 要求を独立した sub task に分解できる
- orchestrator / agent / skill の境界を明確に定義できる
- 各コンポーネントの入力、出力、依存関係を説明できる
- 並列実装またはコンテキスト分離による利得が明確にある
- 各実装単位の write scope を分離できる
- 単一 skill と補助 reference / script だけでは不足する理由を説明できる

## multi-agent を採用しない条件

次のどれかが強い場合は multi-agent を採用しない。

- 単一 skill で十分に表現できる
- 生成物の中心が 1 つの skill folder だけである
- 役割を分けても実質的には逐次実行になる
- 各担当が同じ file や directory を編集する
- 責務境界が曖昧で統合コストの方が高い
- wrapper を増やしても利用価値がほとんど増えない

迷う場合は通常の `skill-creator` フローへフォールバックする。

## 一時 agent と永続 agent の使い分け

まず一時的な新規 agent context で十分かを検討する。

一時 agent を優先する条件:

- 今回限りの分担実装である
- 固定の model / sandbox / developer instructions を将来も使い回す必要がない
- 目的が恒久的な role 定義ではなく、作業分担そのものである

永続 agent を作る条件:

- 将来も同じ role を繰り返し使う
- role ごとに model / sandbox / developer instructions を固定したい
- 実行環境として残す価値がある

見栄えのためだけに永続 agent を増やさない。

## orchestrator / agent / skill の責務分離

### orchestrator

orchestrator は薄く保つ。

責務は次に限定する。

- 依頼整理
- タスク分解
- 実行順序の決定
- 依存関係の管理
- 結果集約
- 最終報告

orchestrator に実装責務を持たせない。

orchestrator は実行 agent を持たない。

orchestrator skill は、子 skill 実装後に新しい `agents.skill-creator` agent を起動して実装する。

### agent

agent は最小限の実行環境として扱う。

agent 作成・更新では `agent-creator` skill を使う。

agent config には role、model、reasoning、sandbox、短い恒久ルールだけを書く。

workflow や acceptance criteria を agent config に埋め込まない。

### skill

skill は再利用可能な workflow として扱う。

skill 作成・更新では `skill-creator` skill を使う。

子 skill は 1 つの job に集中させる。

子 skill では必要な実行 agent を明示する。

multi-agent 分岐では、1 つの子 skill に対して 1 つの実行 agent を割り当てる。

## 並列化の可否判断

次をすべて満たす場合だけ並列化する。

- 各実装単位の責務が固定されている
- write scope が重ならない
- 入出力契約が先に確定している
- 相互参照しながら同時編集する必要がない

次のいずれかに当てはまる場合は逐次実行に切り替える。

- 同じ skill directory を編集する
- 同じ reference file を編集する
- 共有ドラフトが固まっていない
- 前工程の出力を見ないと後続が進められない

特に次の共有 file は並列編集しない。

- `~/.codex/config.toml`
- 単一の orchestrator skill directory
- 共有 reference / template file

複数の永続 agent を作る場合でも、`~/.codex/config.toml` の更新 owner は 1 実装単位に固定するか、逐次でマージする。

## plan 固定と承認ゲート

実装前に plan を固定してユーザーへ提示する。

plan には少なくとも次を含める。

- multi-agent を採用する理由
- orchestrator / agent / skill の一覧
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

## 実装順序

1. この文書で multi-agent 要否を判定する。
2. 不要なら通常の `skill-creator` フローへフォールバックする。
3. 必要なら full component map を設計する。
4. ユーザーに実装 plan を提示して承認を得る。
5. 承認後、子 skill ごとに新しい `agents.skill-creator` agent を起動して新しいコンテキストで実装する。
6. 各子 skill 実装の中で、agent 作成タスクには `agent-creator` を使い、skill 作成タスクには `skill-creator` を使う。
7. write conflict がない子 skill だけを並列実装する。
8. すべての子 skill 完了後に、新しい `agents.skill-creator` agent を起動して orchestrator skill を実装する。
9. 実装した skill を検証してから最終報告する。

## 最終報告

multi-agent 分岐の最終報告には少なくとも次を含める。

- 各 orchestrator / agent / skill の概要
- 各 orchestrator / agent / skill の利用方法
- どの部分を並列実装したか
- 必要な follow-up
