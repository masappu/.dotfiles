# Multi-Agent Guidelines

## 目的

新しい skill 作成依頼に対して、multi-agent を採用するべきか、通常の単一 skill 作成に留めるべきかを判断するための基準を定義する。

この判断では「分割できるか」ではなく、「multi-agent にすると再利用性、責務分離、並列実装、コンテキスト分離の利得が本当に増えるか」を見る。

## multi-agent を採用する条件

次のいずれかに明確な利点がある場合、
multi-agent の採用を検討する。

- 責務ごとに agent / skill を分離すると理解しやすくなる
- コンテキストを分離した方が reasoning が安定する
- 実装を段階的に進める workflow が必要
- 並列実装により作業効率が上がる
- 将来同じ workflow を再利用する可能性が高い

## multi-agent を採用しない条件

次のどれかが強い場合は multi-agent を採用しない。

- 単一 skill で十分に表現できる
- 役割を分けても責務の違いがほとんどない

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

### agent

agent は最小限の実行環境として扱う。

agent 作成・更新では `agent-creator` skill を使う。

agent config には role、model、reasoning、sandbox、短い恒久ルールだけを書く。

workflow や acceptance criteria を agent config に埋め込まない。

### skill

skill は再利用可能な workflow として扱う。

skill 作成・更新では `skill-creator` skill を使う。

子 skill は 1 つの job に集中させる。

子 skillをsub agentにて実行する場合は実行 agent を明示する。

## skill と agent の対応

multi-agent 前提の子 skill には、
原則として専用 agent を割り当てる。

これにより次が可能になる。

- skill ごとの model / reasoning / sandbox 調整
- reasoning context の分離
- 実行環境チューニング

ただし次の場合は agent を共有してもよい。

- 実行環境が完全に同一
- role が実質的に同じ
- 将来の独立調整の必要性が低い

見栄えのためだけに agent を共通化しない。

## 並列化の可否判断

並列化は任意とする。

write conflict の可能性がある場合は
逐次実行に切り替える。

## 最終報告

multi-agent 分岐の最終報告には少なくとも次を含める。

- 各 orchestrator / agent / skill の概要
- 各 orchestrator / agent / skill の利用方法
- どの部分を並列実装したか
- 必要な follow-up
