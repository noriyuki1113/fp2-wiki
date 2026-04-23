-- ============================================================
-- FP2試験対策SaaS — Supabaseスキーマ定義
-- ============================================================

-- -----------------------------------------------
-- questions（問題）
-- wikiのJSONと仕様書を統合したスキーマ
-- -----------------------------------------------
CREATE TABLE questions (
  id              text PRIMARY KEY,          -- 例: "2025_05_g_001"
  year            int         NOT NULL,      -- 出題年度 (例: 2025)
  month           int         NOT NULL,      -- 出題月   (例: 5)
  exam_type       text        NOT NULL DEFAULT 'gakka',  -- 'gakka' | 'jitsugi'
  field           text        NOT NULL,      -- 分野コード (life/risk/finance/tax/realestate/inheritance)
  question_number int         NOT NULL,      -- 問番号 (1〜60)
  question        text,                      -- 問題文（将来追加）
  options         jsonb,                     -- 選択肢 [{ key: "1", text: "..." }, ...]
  answer          text        NOT NULL,      -- 正解のkey ("1"〜"4")
  explanation     text,                      -- 解説文（将来追加 / AI生成）
  topic           text,                      -- 論点スラッグ (例: fp_ethics_law)
  is_frequent     boolean     NOT NULL DEFAULT false,  -- 頻出論点フラグ
  created_at      timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT questions_field_check CHECK (
    field IN ('life', 'risk', 'finance', 'tax', 'realestate', 'inheritance')
  ),
  CONSTRAINT questions_month_check CHECK (month IN (1, 5, 9)),
  CONSTRAINT questions_answer_check CHECK (answer IN ('1', '2', '3', '4'))
);

-- 複合ユニーク制約（同一試験の問番号は1つだけ）
CREATE UNIQUE INDEX questions_exam_qnum_idx ON questions (year, month, exam_type, question_number);

-- -----------------------------------------------
-- users（ユーザー）
-- Supabase Auth の user.id と連携
-- -----------------------------------------------
CREATE TABLE users (
  id          uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  plan        text        NOT NULL DEFAULT 'free',
  exam_date   date,
  created_at  timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT users_plan_check CHECK (plan IN ('free', 'standard', 'premium'))
);

-- -----------------------------------------------
-- answers（回答履歴）
-- -----------------------------------------------
CREATE TABLE answers (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  question_id  text        NOT NULL REFERENCES questions(id),
  selected     text        NOT NULL,
  is_correct   boolean     NOT NULL,
  answered_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX answers_user_id_idx ON answers (user_id);
CREATE INDEX answers_question_id_idx ON answers (question_id);

-- -----------------------------------------------
-- study_plans（学習プラン）
-- -----------------------------------------------
CREATE TABLE study_plans (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plan_json    jsonb       NOT NULL,
  generated_at timestamptz NOT NULL DEFAULT now()
);

-- -----------------------------------------------
-- Row Level Security
-- -----------------------------------------------

ALTER TABLE questions   ENABLE ROW LEVEL SECURITY;
ALTER TABLE users       ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers     ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plans ENABLE ROW LEVEL SECURITY;

-- questions: 全員が読める（無料プランの制限はアプリ側で制御）
CREATE POLICY "questions_select_all"
  ON questions FOR SELECT USING (true);

-- users: 自分のレコードのみ読み書き可
CREATE POLICY "users_select_own"
  ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "users_update_own"
  ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "users_insert_own"
  ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- answers: 自分の回答履歴のみ
CREATE POLICY "answers_select_own"
  ON answers FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "answers_insert_own"
  ON answers FOR INSERT WITH CHECK (auth.uid() = user_id);

-- study_plans: 自分のプランのみ
CREATE POLICY "study_plans_select_own"
  ON study_plans FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "study_plans_insert_own"
  ON study_plans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "study_plans_update_own"
  ON study_plans FOR UPDATE USING (auth.uid() = user_id);

-- -----------------------------------------------
-- 無料プランの月20問制限ビュー（参考）
-- アプリ側でこのビューを使ってカウント確認する
-- -----------------------------------------------
CREATE VIEW monthly_answer_counts AS
SELECT
  user_id,
  date_trunc('month', answered_at) AS month,
  count(*) AS answer_count
FROM answers
GROUP BY user_id, date_trunc('month', answered_at);
