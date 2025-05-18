from datetime import datetime, timezone, timedelta

JST = timezone(timedelta(hours=9))


def validate_and_convert_event_data(data: dict) -> dict:
    """イベントデータのバリデーションと日時の変換を行う。Firestore登録前に使用。"""
    allowed_keys = {
        "title",
        "start_time",
        "end_time",
        "location",
        "address",
        "notify_at",
    }
    required_fields = ["title", "start_time", "end_time"]

    extra_keys = set(data.keys()) - allowed_keys
    if extra_keys:
        raise ValueError(f"不正なキーが含まれています: {', '.join(extra_keys)}")

    for field in required_fields:
        if field not in data:
            raise ValueError(f"'{field}' は必須です")

    try:
        for key in ["start_time", "end_time", "notify_at"]:
            if key in data:
                dt = datetime.fromisoformat(data[key].replace("Z", "+00:00"))
                if dt.tzinfo is None:
                    dt = dt.replace(tzinfo=JST)
                data[key] = dt
    except Exception:
        raise ValueError(
            "日時フィールドはISO形式（例: 2025-06-01T09:00:00+09:00）で指定してください"
        )

    return data
