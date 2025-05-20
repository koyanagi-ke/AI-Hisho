import base64
import json


def get_user_id_from_request(headers) -> str:
    """
    API Gateway によって付与された x-apigateway-api-userinfo ヘッダーを解析し、
    Firebase の user_id（uid）を取得する。

    Raises:
        ValueError: ヘッダーが欠けている、またはデコードに失敗した場合。
    """
    userinfo_b64 = headers.get("x-apigateway-api-userinfo")
    if not userinfo_b64:
        raise ValueError("Missing x-apigateway-api-userinfo header")

    try:
        # Base64の長さを4の倍数に補正（不足分だけ = を追加）
        padding = "=" * ((4 - len(userinfo_b64) % 4) % 4)
        decoded_str = base64.b64decode(userinfo_b64 + padding)
        decoded = json.loads(decoded_str)
        return decoded.get("user_id") or decoded.get("sub")
    except Exception as e:
        raise ValueError(f"Failed to decode x-apigateway-api-userinfo: {e}")
