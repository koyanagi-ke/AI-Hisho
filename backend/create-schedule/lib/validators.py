from datetime import datetime, timezone, timedelta
from .exceptions import ValidationError

JST = timezone(timedelta(hours=9))


def validate_and_convert_event_data(data: dict, is_update=False) -> dict:
    """イベントデータのバリデーションと日時の変換を行う。Firestore登録前に使用。"""
    allowed_keys = {
        "title",
        "start_time",
        "end_time",
        "location",
        "address",
        "notify_at",
    }
    required_fields = ["title", "start_time", "end_time", "location"]

    extra_keys = set(data.keys()) - allowed_keys
    if extra_keys:
        raise ValidationError(f"不正なキーが含まれています: {', '.join(extra_keys)}")

    if not is_update:
        for field in required_fields:
            if field not in data:
                raise ValidationError(f"'{field}' は必須です")

    try:
        for key in ["start_time", "end_time", "notify_at"]:
            if key in data:
                data[key] = _parse_datetime_field(data[key])
    except Exception:
        raise ValidationError(
            "日時フィールドはISO形式（例: 2025-06-01T09:00:00+09:00）で指定してください"
        )

    return data


def _parse_datetime_field(value: str) -> datetime:
    """ISO形式の日時文字列をdatetime型に変換（JSTに補正）"""
    if value.endswith("Z"):
        # ZはUTCを示す → JSTに変換
        dt = datetime.fromisoformat(value.replace("Z", "+00:00"))
        return dt.astimezone(JST)
    else:
        dt = datetime.fromisoformat(value)
        # タイムゾーンがなければ JST を付ける
        return dt if dt.tzinfo else dt.replace(tzinfo=JST)
