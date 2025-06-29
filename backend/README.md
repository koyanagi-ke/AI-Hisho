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

| パラメータ名 | 型     | 必須 | 説明                                                     |
| ------------ | ------ | ---- | -------------------------------------------------------- |
| `title`      | string | ✅   | イベントのタイトル                                       |
| `start_time` | string | ✅   | イベントの開始日時（ISO8601 形式、JST 推奨）             |
| `end_time`   | string | ✅   | イベントの終了日時（ISO8601 形式、JST 推奨）             |
| `location`   | string | ✅️  | イベントの開催場所（例：吉祥寺）                         |
| `address`    | string | ❌   | 緯度経度取得用の住所。未指定時は Gemini により補完される |
| `notify_at`  | string | ❌   | 通知を送る日時（ISO8601 形式）                           |

- `address` は未指定時、Gemini API によって補完されます
- `notification_sented`: false が自動追加されます

#### 📤 レスポンス例

```json
{ "id": "pO1acejHhke3HgCSZqLc" }
```

| フィールド名 | 型     | 説明                        |
| ------------ | ------ | --------------------------- |
| `id`         | string | 作成されたスケジュールの ID |

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
  "weather_advice": "ハワイは晴れのち曇り、日中は少し風が強そうなので、羽織るものがあると安心です。",
  "weather_info": "{city: {sunrise: 1750520655, country: US, sunset: 1750568583, timezone: -36000, name: ハワイ郡, id: 5855765, population: 185079, coord: {lon: -155.4487, lat: 19.5896}}, list: [{visibility: 10000, dt: 1750582800, weather: [{id: 800, description: 晴天, icon: 01n, main: Clear}], sys: {pod: n}, pop: 0, wind: {gust: 5.2, deg: 110, speed: 2.86}, clouds: {all: 2}, main: {temp_max: 12.36, humidity: 50, temp_kf: 0.4, grnd_level: 773, pressure: 1025, sea_level: 1025, temp_min: 11.96, feels_like: 10.96, temp: 12.36}, dt_txt: 2025-06-22 09:00:00}, {visibility: 10000, dt: 1750593600, weather: [{id: 800, description: 晴天, icon: 01n, main: Clear}",
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

| フィールド名     | 型     | 説明                 |
| ---------------- | ------ | -------------------- |
| `id`             | string | スケジュールの ID    |
| `title`          | string | イベントのタイトル   |
| `start_time`     | string | 開始日時（ISO 形式） |
| `end_time`       | string | 終了日時（ISO 形式） |
| `location`       | string | イベントの開催場所   |
| `next_check_due` | string | 次の持ち物準備の期日 |
| `checklists`     | array  | チェックリストの配列 |
| `weather_advice` | string | 天気のアドバイス     |
| `weather_info`   | dict   | 天気の情報           |

checklists 配下の項目
| フィールド名 | 型 | 説明 |
| ---------------- | ------ | ------------- |
| `id` | string | checklist_id(持ち物 ID) |
| `item` | string | 持ち物名 |
| `prepare_before` | int | 開始日の何日前に準備するか |
| `checked` | bool | 準備済みかどうか |
| `required` | bool | 必須アイテムかどうか |

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

| パラメータ名 | 型     | 必須 | 説明                       |
| ------------ | ------ | ---- | -------------------------- |
| `id`         | string | ✅   | 更新対象のイベント ID      |
| `title`      | string | ❌   | タイトル（任意で更新可能） |
| `start_time` | string | ❌   | 開始日時（ISO 形式）       |
| `end_time`   | string | ❌   | 終了日時（ISO 形式）       |
| `location`   | string | ❌   | 開催場所                   |
| `address`    | string | ❌   | 開催地の住所               |
| `notify_at`  | string | ❌   | 通知日時（ISO 形式）       |

#### 📤 レスポンス例

```
{"status": "updated"}
```

| フィールド名 | 型     | 説明                            |
| ------------ | ------ | ------------------------------- |
| `status`     | string | 更新成功時は `"updated"` を返す |

---

### 🔸 DELETE `/api/crud-schedule`

スケジュールを削除します。

#### 📥 リクエスト Body

```json
{ "id": "pO1acejHhke3HgCSZqLc" }
```

| パラメータ名 | 型     | 必須 | 説明                  |
| ------------ | ------ | ---- | --------------------- |
| `id`         | string | ✅   | 削除対象のイベント ID |

#### 📤 レスポンス例

```json
{ "status": "deleted" }
```

| フィールド名 | 型     | 説明                            |
| ------------ | ------ | ------------------------------- |
| `status`     | string | 削除成功時は `"deleted"` を返す |

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

| パラメータ名 | 型     | 必須 | 説明                        |
| ------------ | ------ | ---- | --------------------------- |
| `fcm_token`  | string | ✅   | 登録する端末の FCM トークン |

#### 📤 レスポンス

```json
{ "status": "ok" }
```

| フィールド名 | 型     | 説明                       |
| ------------ | ------ | -------------------------- |
| `status`     | string | 登録成功時は `"ok"` を返す |

---

## 3. 🔔 期日切れ持ち物があるスケジュール確認 API（ユーザー自発）

### GET `/api/reminder`

**今日以降に開始する予定のうち、「今日が持ち物準備開始日に該当するイベント」を一覧で返します。**

この API はバッチ通知とは異なり、ユーザーが明示的に確認したいときに利用できます。
持ち物が必要であれば本 API で各スケジュールの id が手に入るので、スケジュールの getAPI を利用する

#### 📥 リクエストパラメータ

- なし（ユーザー ID はトークンから内部で取得）

#### 📤 レスポンス例

```json
[
  {
    "event_id": "pO1acejHhke3HgCSZqLc",
    "title": "遠足",
    "start_time": "2025-05-21T09:00:00+09:00",
    "end_time": "2025-05-21T15:00:00+09:00",
    "location": "東京"
  },
  {
    "event_id": "abc123xyz",
    "title": "出張（名古屋）",
    "start_time": "2025-05-22T10:00:00+09:00",
    "end_time": "2025-05-22T17:00:00+09:00",
    "location": "東京"
  }
]
```

| フィールド名 | 型     | 説明                         |
| ------------ | ------ | ---------------------------- |
| `event_id`   | string | 該当イベントの ID            |
| `title`      | string | イベントのタイトル           |
| `start_time` | string | イベント開始日時（ISO 形式） |
| `end_time`   | string | イベント終了日時（ISO 形式） |
| `location`   | string | イベントの開催場所           |

---

## 4. ✅ チェックリストの完了状態を切り替える API

### POST `/api/checklist-toggle`

**指定されたチェックリスト項目の `checked` 状態（完了/未完了）を切り替えます。**

#### 📥 リクエストボディ

```json
{
  "event_id": "abc123event",
  "checklist_id": "item456",
  "checked": true
}
```

| パラメータ名   | 型     | 必須 | 説明                        |
| -------------- | ------ | ---- | --------------------------- |
| `event_id`     | string | ✅   | 対象イベントの ID           |
| `checklist_id` | string | ✅   | 更新対象のチェックリスト ID |
| `checked`      | bool   | ✅   | 更新後の状態（true = 完了） |

※ユーザー ID は Firebase トークンから取得され、明示的に送信する必要はありません。

#### 📤 レスポンス例

```json
{
  "status": "success",
  "next_check_due": "2025-05-29T00:00:00+09:00"
}
```

| フィールド名     | 型             | 説明                                                          |
| ---------------- | -------------- | ------------------------------------------------------------- |
| `status`         | string         | 固定で `"success"`                                            |
| `next_check_due` | string or null | 未完了アイテムがある場合はその最速準備開始日、なければ `null` |

---

## 5. 🗓️ メッセージ履歴から予定を抽出する API

### POST `/api/message-schedule`

**複数人のチャット履歴をもとに、Gemini を使って予定のタイトル・日時・場所を抽出し、構造化された JSON で返します。**
入力されたチャット履歴を文脈的に解析し、イベントの開始/終了日時、場所、内容を自然な形で推定します。

#### 📥 リクエストボディ

```json
{
  "message": [
    { "role": "user", "parts": [{ "text": "土曜日の朝にサッカーやろうよ" }] },
    {
      "role": "model",
      "parts": [{ "text": "9時に武蔵野スポーツセンター集合で！" }]
    },
    {
      "role": "model",
      "parts": [{ "text": "14:30には帰りたいから、それまでね！" }]
    }
  ]
}
```

| パラメータ名 | 型            | 必須 | 説明                                                                        |
| ------------ | ------------- | ---- | --------------------------------------------------------------------------- |
| `message`    | list\[object] | ✅   | チャットの履歴。各要素は `{"role": string, "parts": list[object]}` の形式。 |

チャットの履歴のパラメータ
| パラメータ名 | 型 | 必須 | 説明 |
| --------- | ------------- | -- | -------------------------------------------------------- |
| `role` | string | ✅ | ロール名`"user"` または `"friend"` など、話者識別用の任意ラベル |
| `parts` | list\[object] | ✅ | `"text"`をキーに持つオブジェクト。`"text"`にはメッセージ内容が入る |

---

#### 📤 レスポンス例

```json
{
  "event_id": "abc123",
  "title": "サッカーの試合",
  "start_time": "2025-05-31T09:00:00+09:00",
  "end_time": "2025-05-31T14:30:00+09:00",
  "location": "武蔵野スポーツセンター"
}
```

| フィールド名 | 型     | 説明                                   |
| ------------ | ------ | -------------------------------------- |
| `event_id`   | string | 対象イベントの ID                      |
| `title`      | string | 推定されたイベント名（自然な日本語）   |
| `start_time` | string | イベントの開始日時（JST ISO8601 形式） |
| `end_time`   | string | イベントの終了日時（JST ISO8601 形式） |
| `location`   | string | 推定された開催場所                     |

---

## 6. 🗓 スケジュール取得 API

### 🔸 POST `/api/schedules`

指定した期間のスケジュール一覧を取得します。

- 認証：必須
- Content-Type：`application/json`

#### 📥 リクエスト Body

```json
{
  "start_time": "2025-05-01T00:00:00+09:00",
  "end_time": "2025-05-31T23:59:59+09:00"
}
```

| パラメータ名 | 型     | 必須 | 説明                                       |
| ------------ | ------ | ---- | ------------------------------------------ |
| `start_time` | string | ✅   | 取得対象期間の開始日時（JST ISO8601 形式） |
| `end_time`   | string | ✅   | 取得対象期間の終了日時（JST ISO8601 形式） |

#### 📤 レスポンス例

```json
[
  {
    "event_id": "abc123",
    "title": "遊びに行く",
    "start_time": "2025-06-15T00:00:00+00:00",
    "end_time": "2025-06-15T12:00:00+00:00",
    "location": "海遊館"
  }
]
```

| フィールド名 | 型     | 説明                           |
| ------------ | ------ | ------------------------------ |
| `event_id`   | string | 対象イベントの ID              |
| `title`      | string | イベントのタイトル             |
| `start_time` | string | イベントの開始日時（ISO 形式） |
| `end_time`   | string | イベントの終了日時（ISO 形式） |
| `location`   | string | イベントの開催場所             |

- 期間内に該当するスケジュールがない場合は空配列 `[]` を返します

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
