---
marp: true
theme: default
paginate: true
size: 16:9
headingDivider: false
style: |
  @import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+JP:wght@400;500;700&family=IBM+Plex+Mono:wght@400;500&display=swap');
  section {
    font-family: "IBM Plex Sans JP", "Hiragino Sans", sans-serif;
    color: #1a1d23;
    background: #f6f4ef;
    padding: 52px 64px;
    letter-spacing: 0.01em;
  }
  h1, h2, h3 { font-weight: 700; letter-spacing: -0.02em; }
  h1 { color: #111318; }
  h2 { color: #111318; }
  section.title {
    background: #111318;
    color: #f6f4ef;
  }
  section.title h1 { color: #f6f4ef; font-size: 52px; }
  section.title p { color: #c8c2b4; }
  section.kicker h2 { color: #c45c26; font-size: 22px; margin-bottom: 8px; }
  section.kicker h1 { font-size: 40px; }
  section.dark {
    background: #111318;
    color: #f6f4ef;
  }
  section.dark h1, section.dark h2 { color: #f6f4ef; }
  section.dark th { background: #2a2e36; color: #f6f4ef; }
  section.dark td { background: #1a1d23; color: #f6f4ef; }
  code, pre {
    font-family: "IBM Plex Mono", ui-monospace, monospace;
    background: #ebe6db;
  }
  table { font-size: 22px; }
  th { background: #e7e1d4; }
  td, th { padding: 8px 12px; }
  .muted { color: #6b6f78; }
  .lead { font-size: 28px; line-height: 1.5; }
  .big { font-size: 64px; font-weight: 700; line-height: 1.15; }
  .num { font-family: "IBM Plex Mono", ui-monospace, monospace; font-weight: 500; }
  footer { color: #8a8478; font-size: 14px; }

  section.ex pre { font-size: 15px; line-height: 1.35; }
  .columns {
    display: grid;
    grid-template-columns: 0.8fr 1.2fr;
    gap: 28px;
    align-items: start;
  }
  .columns table { font-size: 18px; margin: 0; }
  .columns td, .columns th { padding: 6px 10px; }
---

<!-- _class: title -->
<!-- _paginate: false -->
<!-- _class: kicker -->

# JEV で静的解析はできるか

30 件を JEV に聞いて、同じ問いを Claude にも投げてみた

---

<!-- _class: kicker -->

## なぜ試したか

# JEV なら、もっと気軽にできないか

linter も Claude も賢くなって、人間が気付きにくいエラーを見つけてくれる。
同じことを JEV で、問いを投げるだけでできないか試した。

---

<!-- _class: kicker -->

## JEV とは何か

# 文章は返ってこない。数字だけ

確率を返すAI。
コードと問いを送ると、数値だけが返る。理由は書いてくれない。
1回で複数の問いを同時に聞ける。

| 型         | 聞くこと   | 戻り値            |
| ---------- | ---------- | ----------------- |
| **noul**   | これは真か | 0.0–1.0 の確率    |
| **choice** | どれか     | 当選ラベル + 分布 |
| **score**  | 何段階か   | 順序尺度上の位置  |

今回は `jev-1.13.0`。入力 100 万トークンあたり $0.042、出力は無料。

---

<!-- _class: kicker -->

## JEV で何をしたか 検証方法1

# 3区分でざっくりと判別

1つ目は good / gray / bad の3軸をchoiceで、ざっくり適切でないコードかを分けた。
サンプルコードは30 件。言語はGo。
ファイル名やディレクトリ階層、パッケージ名では判別不可。

| 区分     | 件数 | 意味                         |
| -------- | ---- | ---------------------------- |
| **good** | 10   | 言語慣習とベストプラクティス |
| **gray** | 10   | 設計意図や環境で許容が変わる |
| **bad**  | 10   | コードパスによらず修正必須   |

---

<!-- _class: kicker -->

## 検証方法1の結果

# 3区分の結果

jev-1.13.0 / 意味の文章はそのまま使用

| 区分     | 正答        |
| -------- | ----------- |
| good     | **9 / 10**  |
| gray     | **6 / 10**  |
| bad      | **3 / 10**  |
| **合計** | **18 / 30** |

good は高スコア。
bad は想像よりも低スコアかつ2/10がgoodと判定された。
gray も3/10がgoodと判定された。

---

<!-- _class: kicker -->

## JEV で何をしたか 検証方法2

# 6軸でコード内に含む指摘箇所を判別

2つ目は ctx / err / conc / sec / resource / api
どの種類の指摘箇所が含まれるかをnoulで、各軸ごとに分けた。

| 軸           | 見ていること                                                                   |
| ------------ | ------------------------------------------------------------------------------ |
| **ctx**      | コンテキストの伝播が欠落しており、キャンセル・タイムアウトが機能しない         |
| **err**      | エラーが握りつぶされているか、呼び出し元に適切に返却されていない               |
| **conc**     | goroutine のリーク・データレース・排他制御の欠落など並行処理の安全性問題       |
| **sec**      | SQLインジェクションや機微情報の外部露出などセキュリティリスク                  |
| **resource** | ファイルや接続などのリソースが適切に解放されない、または解放エラーが無視される |
| **api**      | 公開 API が通常の入力で panic するか、戻り値の契約が不明瞭                     |

---

<!-- _class: kicker -->

## JEV の結果

# 6軸の結果

0.70 以上を検出。分母は、その軸が付いているファイル数。
6 軸のうち1つでも当てはまったらエラーを含むファイルと判別する。

| 軸           | 拾えた    | 関係ないのに反応 |
| ------------ | --------- | ---------------- |
| **sec**      | **2 / 2** | 0                |
| **ctx**      | **4 / 6** | 3                |
| **err**      | **3 / 7** | 1                |
| **conc**     | **0 / 7** | 0                |
| **resource** | **0 / 3** | 0                |
| **api**      | **0 / 5** | 0                |

---

<!-- _class: kicker -->

## JEV の結果 気づいた点

# bad なのに good が 2 件

| ファイル | 3区分 | 中身 |
| --- | --- | --- |
| `race_on_map` | **good 0.69** | `counts[key]++` だけ。goroutine はファイルにない |
| `ignore_close_error` | **good 0.39** | 捨てているのは `Close` だけ |

---

<!-- _class: kicker -->

## JEV の結果 気づいた点

# api は難しい。conc と resource は可能性あり

api は 5 件とも 0.70 未満。空文字で panic する `panic_in_lib` も **0.41**。

conc と resource の本命は 0 件。ただし 0 ではなく、0.4〜0.6 まで上がっている。

| ファイル | 軸 |
| --- | --- |
| `race_on_map` | conc **0.59** |
| `leaky_goroutine` | conc **0.68** |
| `ignore_close_error` | resource **0.56** |
| `optional_err_ignore` | resource **0.62** |

---

<!-- _class: kicker -->

## 同じ実験を Claude で

# 同じ 30 件、同じ 3区分と6軸

Sonnet 4.6。3区分と 6軸を、JEV と同じ定義で判定させた。
軸は 0.70 以上を「エラーあり」。

| 区分     | 正答        |
| -------- | ----------- |
| good     | **8 / 10**  |
| gray     | **8 / 10**  |
| bad      | **6 / 10**  |
| **合計** | **22 / 30** |

gray の1つが誤って good となった。外れた bad は いずれも gray と判定。

---

<!-- _class: kicker -->

## 同じ実験を Claude で

# 6軸で、本命を何件拾えたか

0.70 以上を検出。分母は JEV と同じで、その軸が付いているファイル。

| 軸       | 拾えた    | 関係ないのに反応 |
| -------- | --------- | ---------------- |
| sec      | **2 / 2** | 0                |
| ctx      | **3 / 6** | 0                |
| conc     | **3 / 7** | 0                |
| err      | **1 / 7** | 1                |
| resource | **1 / 3** | 1                |
| api      | **1 / 5** | 0                |

---

<!-- _class: kicker -->

## 比較

# JEV 17/30、Claude 22/30

|        | 区分の正答  | 強いところ                            | 費用    | 時間    |
| ------ | ----------- | ------------------------------------- | ------- | ------- |
| JEV    | **18 / 30** | sec / err。3区分と6軸がずれる         | $0.0009 | 約40s   |
| Claude | **22 / 30** | 3区分も6軸も安定。good への軸誤爆なし | $0.51   | 約3m40s |

JEV は Claude の約 **1/550** の費用で、正答は 5 件少ない。時間は約 5 倍。
Claude の方が、gray / bad を good と判定した数が少ない。

---

<!-- _class: kicker -->

## 結果

# 静的解析できなくはない。まだ代わりとして使うには難しい。

- 30 件を数字だけで判定できた。当たったのは **17 / 30**
- 同じことを Claude に聞くと **22 / 30**。費用は約 550 倍

時間があったら、ファイル数を増やす、テストコードが適切かとか試してみたい。

---

<!-- _class: title -->
<!-- _paginate: false -->
<!-- _class: kicker -->

# JEV で静的解析はできるか

30 件を JEV に聞いて、同じ問いを Claude にも投げてみた
