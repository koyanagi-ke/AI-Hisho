from .exceptions import ValidationError


def validate_exact_fields(data: dict, allowed_fields: list[str]):
    """
    必須かつ許可されたフィールドのみが存在するか検証。

    Args:
        data (dict): リクエストボディ
        allowed_fields (list): 許可されたフィールド名（必須項目）

    Raises:
        ValueError: 欠落 or 余計なフィールドがある場合
    """
    missing = [field for field in allowed_fields if field not in data]
    extra = [field for field in data if field not in allowed_fields]

    if missing:
        raise ValidationError(f"Missing required field(s): {', '.join(missing)}")
    if extra:
        raise ValidationError(f"Unexpected field(s): {', '.join(extra)}")


def validate_gemini_messages(data: dict):
    messages = data.get("message")
    if not isinstance(messages, list):
        raise ValidationError("message must be a list")

    for i, msg in enumerate(messages):
        if not isinstance(msg, dict):
            raise ValidationError(f"Message at index {i} must be a dict")
        if "role" not in msg or "parts" not in msg:
            raise ValidationError(
                f"Each message must contain 'role' and 'parts' (index {i})"
            )
        if not isinstance(msg["parts"], list):
            raise ValidationError(f"'parts' must be a list (index {i})")
        for part in msg["parts"]:
            if not isinstance(part, dict) or "text" not in part:
                raise ValidationError(
                    f"Each part must be a dict with 'text' (index {i})"
                )
