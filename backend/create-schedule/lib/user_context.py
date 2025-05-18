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
        decoded = json.loads(base64.b64decode(userinfo_b64))
        return decoded.get("user_id") or decoded.get("sub")
    except Exception as e:
        raise ValueError(f"Failed to decode x-apigateway-api-userinfo: {e}")
