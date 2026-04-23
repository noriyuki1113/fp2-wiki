"""
wiki/questions/*.md を読み込み、Supabase投入用JSONを生成する。

使い方:
  python import_questions.py > questions.json

出力:
  { "questions": [ { "id": "2024_05_g_001", ... }, ... ] }
"""

import re
import json
from pathlib import Path

WIKI_DIR = Path(__file__).parent.parent.parent / "wiki" / "questions"

# 論点テキスト → topicスラッグのマッピング
TOPIC_MAP = {
    "FP業務と関連法規": "fp_ethics_law",
    "FP職業倫理": "fp_ethics_law",
    "FP関連法規": "fp_ethics_law",
    "老齢年金の繰上げ・繰下げ": "nenkin_hikiage_sagari",
    "老齢厚生年金の繰下げ": "nenkin_hikiage_sagari",
    "老齢給付の繰上げ": "nenkin_hikiage_sagari",
    "老齢給付の繰上げ・繰下げ": "nenkin_hikiage_sagari",
    "公的医療保険": "kenko_hoken",
    "健康保険（協会けんぽ）": "kenko_hoken",
    "協会けんぽ": "kenko_hoken",
    "協会けんぽ短時間労働者": "kenko_hoken",
    "育児休業給付・介護休業給付": "ikuji_kaigo_kyufu",
    "生命保険の商品性": "seiho_shouhin",
    "生命保険料控除": "seiho_ryokin_kojyo",
    "法人保険の経理処理": "hojin_seiho_keiri",
    "法人損害保険の経理処理": "hojin_seiho_keiri",
    "地震保険": "jishin_hoken",
    "傷害保険": "jishin_hoken",
    "損害保険の商品性": "jishin_hoken",
    "損益通算": "son_eki_tsukan",
    "損益通算・総所得金額": "son_eki_tsukan",
    "損益通算・総所得金額計算": "son_eki_tsukan",
    "損益通算・総所得金額": "son_eki_tsukan",
    "小規模宅地等の特例": "shoukibo_takuchi",
    "債券利回り計算": "saiken_rimawari",
    "債券": "saiken_rimawari",
    "ポートフォリオ期待収益率": "portfolio_kitai_rimawari",
    "ポートフォリオ理論": "portfolio_kitai_rimawari",
}

# is_frequent = True にする topicスラッグ（hindo_patterns.mdの確定出題論点）
FREQUENT_TOPICS = {
    "fp_ethics_law",
    "son_eki_tsukan",
    "portfolio_kitai_rimawari",
}

# 問番号 → 分野コード
def field_from_qnum(n: int) -> str:
    if 1 <= n <= 10:   return "life"
    if 11 <= n <= 20:  return "risk"
    if 21 <= n <= 30:  return "finance"
    if 31 <= n <= 40:  return "tax"
    if 41 <= n <= 50:  return "realestate"
    if 51 <= n <= 60:  return "inheritance"
    return "unknown"

# ファイル名 g2_YYYYMM.md → (year, month)
def parse_filename(name: str):
    m = re.match(r"g2_(\d{4})(\d{2})", name)
    if m:
        return int(m.group(1)), int(m.group(2))
    return None, None

# 論点テキストからtopicスラッグを解決
def resolve_topic(topic_text: str) -> str | None:
    clean = topic_text.strip().lstrip("*").rstrip("*").strip()
    # ★ マークを除去
    clean = clean.replace(" ★", "").replace("★", "").strip()
    for key, slug in TOPIC_MAP.items():
        if key in clean:
            return slug
    return None

def parse_md_file(path: Path) -> list[dict]:
    year, month = parse_filename(path.stem)
    if year is None:
        return []

    rows = []
    in_table = False

    for line in path.read_text(encoding="utf-8").splitlines():
        # テーブル行を検出（| 問 | 正解 | 論点 | で始まるセクション内）
        if re.match(r"\|\s*問\s*\|", line):
            in_table = True
            continue
        if in_table and re.match(r"\|[-| ]+\|", line):
            continue  # ヘッダー区切り行をスキップ
        if in_table and line.startswith("|"):
            parts = [p.strip() for p in line.strip("|").split("|")]
            if len(parts) < 3:
                continue
            try:
                qnum = int(parts[0])
            except ValueError:
                in_table = False
                continue

            answer = parts[1].strip()
            topic_text = parts[2].strip() if len(parts) > 2 else ""
            topic = resolve_topic(topic_text)

            exam_id = f"{year}_{month:02d}_g_{qnum:03d}"
            rows.append({
                "id":              exam_id,
                "year":            year,
                "month":           month,
                "exam_type":       "gakka",
                "field":           field_from_qnum(qnum),
                "question_number": qnum,
                "question":        None,
                "options":         None,
                "answer":          answer,
                "explanation":     None,
                "topic":           topic,
                "is_frequent":     topic in FREQUENT_TOPICS if topic else False,
            })
        else:
            if in_table and not line.startswith("|"):
                in_table = False

    return rows

def main():
    all_questions = []
    for md_file in sorted(WIKI_DIR.glob("g2_*.md")):
        questions = parse_md_file(md_file)
        all_questions.extend(questions)

    print(json.dumps({"questions": all_questions}, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
