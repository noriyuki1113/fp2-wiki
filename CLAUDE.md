# FP2級 学習wiki 管理ルール

## このwikiの目的
FP2級試験合格のための知識ベース。
過去問・法令・解説を構造化して蓄積する。

## ディレクトリ構成
- raw/ : 元ソース。絶対に編集しない。
- wiki/fields/ : 6分野の概要まとめ
- wiki/topics/ : 論点単位の詳細ページ
- wiki/questions/ : 過去問の解説ページ
- wiki/index.md : 全ページのカタログ
- wiki/log.md : 作業ログ（追記のみ）

## 分野コード
- life : ライフプランニングと資金計画
- risk : リスク管理
- finance : 金融資産運用
- tax : タックスプランニング
- realestate : 不動産
- inheritance : 相続・事業承継

## ページフォーマット（topics/）
---
title: ページタイトル
field: life | risk | finance | tax | realestate | inheritance
tags: []
source_count: 0
last_updated: YYYY-MM-DD
---

## 概要

## 重要ポイント

## 頻出パターン

## 関連論点

## 出題履歴
| 年月 | 問番号 | 出題内容 |
|------|--------|----------|

## インジェストワークフロー
新しいraw/ファイルを処理するとき：
1. ファイルを読む
2. 新しい論点があればwiki/topics/に新規ページ作成
3. 既存ページがあれば更新・矛盾を記録
4. 対象分野のfields/ページを更新
5. index.mdを更新
6. log.mdに ## [日付] ingest | ファイル名 を追記

## クエリワークフロー
質問に答えるとき：
1. index.mdで関連ページを探す
2. 該当ページを読んで回答
3. 良い回答はwiki/topics/に保存
