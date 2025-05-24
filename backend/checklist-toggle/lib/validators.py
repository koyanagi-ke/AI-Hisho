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
