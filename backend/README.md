# 📘 AI-Hisho API 仕様書（ユーザー向けエンドポイント）

この仕様書は、AI-Hisho におけるユーザー操作系 API（スケジュール管理、FCM トークン登録）についてまとめたものです。

---

## 🔐 認証について

全ての API は Firebase 認証（ID トークン）によって保護されています。  
各リクエストには `Authorization: Bearer <Firebase ID Token>` をヘッダーに含めてください。

---

## 🌐 エンドポイント
`https://ai-hisho-hackathon-gw-1oe6tmh6.an.gateway.dev`

---

## 1. 🗓 スケジュール管理 API

### 🔸 POST `/api/crud-schedule`

新規スケジュールを登録します。

- 認証：必須
- Content-Type：`application/json`

#### 📥 リクエスト Body

```json
{
  "title": "サッカーに行く",
  "start_time": "2025-05-17T09:00:00+09:00",
  "end_time": "2025-05-17T14:30:00+09:00",
  "location": "武蔵野スポーツセンター",
  "address": "東京都武蔵野市",
  "notify_at": "2025-05-16T18:00:00+09:00"
}
```

- `title`, `start_time`, `end_time` は必須
- `address` は未指定時、Gemini API によって補完されます
- `notification_sented`: false が自動追加されます

#### 📤 レスポンス例

```json
{ "id": "pO1acejHhke3HgCSZqLc" }
```

---

### 🔸 GET `/api/crud-schedule?event_id={id}`

スケジュール詳細を取得します（持ち物リスト含む）

- 認証：必須
- クエリパラメータ：`event_id` は必須

#### 📤 レスポンス例

```json
{
  "id": "pO1acejHhke3HgCSZqLc",
  "title": "飲み会",
  "start_time": "2025-05-17T09:00:00+00:00",
  "end_time": "2025-05-17T14:30:00+00:00",
  "location": "吉祥寺",
  "next_check_due": "2025-05-14T09:00:00+00:00",
  "checklists": [
    {
      "item": "財布",
      "prepare_before": 2,
      "checked": false,
      "required": true
    },
    ...
  ]
}
```

---

### 🔸 PUT `/api/crud-schedule`

スケジュール情報を更新します。`id` と更新対象フィールドのみ送信してください。

#### 📥 リクエスト例

```json
{
  "id": "pO1acejHhke3HgCSZqLc",
  "location": "新宿",
  "notify_at": "2025-05-15T12:00:00+09:00"
}
```

---

### 🔸 DELETE `/api/crud-schedule`

スケジュールを削除します。

#### 📥 リクエスト Body

```json
{ "id": "pO1acejHhke3HgCSZqLc" }
```

---

## 2. 📲 FCM トークン登録 API

### 🔸 POST `/api/register-fcm-token`

ユーザーの端末 FCM トークンを Firestore に登録します。
複数端末対応のため、トークンはリストとして管理され、重複登録はされません。

#### 📥 リクエスト Body

```json
{
  "fcm_token": "your_device_fcm_token"
}
```

#### 📤 レスポンス

```json
{ "status": "ok" }
```

- Firestore 構造：

  ```
  users/{user_id}
    └─ fcm_tokens: ["token1", "token2", ...]
  ```

---

## 3. 🔔 期日切れ持ち物があるスケジュール確認 API（ユーザー自発）

### GET `/api/reminder-checklist`

**今日以降に開始する予定のうち、「今日が持ち物準備開始日に該当するイベント」を一覧で返します。**

この API はバッチ通知とは異なり、ユーザーが明示的に確認したいときに利用できます。

#### 📥 リクエストパラメータ

- なし（ユーザー ID はトークンから内部で取得）

#### 📤 レスポンス例

```json
[
  {
    "id": "pO1acejHhke3HgCSZqLc",
    "title": "遠足",
    "start_time": "2025-05-21T09:00:00+09:00",
    "end_time": "2025-05-21T15:00:00+09:00"
  },
  {
    "id": "abc123xyz",
    "title": "出張（名古屋）",
    "start_time": "2025-05-22T10:00:00+09:00",
    "end_time": "2025-05-22T17:00:00+09:00"
  }
]
```

---

## 🔒 エラー例（共通）

| ステータス                | 説明                                   |
| ------------------------- | -------------------------------------- |
| 401 Unauthorized          | Authorization ヘッダーが不正または欠如 |
| 400 Bad Request           | リクエスト形式や必須項目の不備         |
| 500 Internal Server Error | サーバー側の予期せぬエラー             |

---

## 📌 補足

- 日付・時刻はすべて ISO8601 形式 + JST（`+09:00`）で統一
- Firestore 上では `DatetimeWithNanoseconds` 型で保存されます
- クライアント側では `.toISOString()` 等で送信を推奨
