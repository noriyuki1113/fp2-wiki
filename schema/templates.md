# テンプレート集

## topics/ ページテンプレート

```markdown
---
title: ページタイトル
field: life | risk | finance | tax | realestate | inheritance
tags: []
source_count: 0
last_updated: YYYY-MM-DD
---

## 概要

<!-- この論点の概要を2〜3文で記述 -->

## 重要ポイント

<!-- 箇条書きで重要な事項を列挙 -->

## 頻出パターン

<!-- 試験でよく問われる切り口・論点のパターンを記述 -->

## 関連論点

<!-- 関連するtopics/ページへのリンク -->

## 出題履歴
| 年月 | 問番号 | 出題内容 |
|------|--------|----------|
```

---

## questions/ ページテンプレート

```markdown
---
title: 過去問 YYYY年MM月 問XX
field: life | risk | finance | tax | realestate | inheritance
exam_date: YYYY-MM
question_number: XX
source: raw/ファイル名
last_updated: YYYY-MM-DD
---

## 問題文

<!-- 問題文をそのまま記載 -->

## 選択肢

1. 
2. 
3. 
4. 

## 正解

**X**

## 解説

<!-- 正解の理由と各選択肢の解説 -->

## 関連論点

<!-- 関連するtopics/ページへのリンク -->
```

---

## log.md エントリフォーマット

```markdown
## [YYYY-MM-DD] ingest | ファイル名
- 処理した内容の概要
- 新規作成したtopics/ページ
- 更新したfields/ページ

## [YYYY-MM-DD] query | 質問の概要
- 参照したページ
- 新規作成・更新したページ（あれば）
```
