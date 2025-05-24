import re
import logging
from google import genai

from .secret_manager_client import get_gemini_api_key

logger = logging.getLogger(__name__)

get_gemini_api_key()
client = genai.Client()
model = "gemini-2.0-flash"


def create_text(contents, model=model):
    response = client.models.generate_content(model=model, contents=contents)
    return response


def infer_address_from_title_and_location(title: str, location: str) -> str:
    prompt = f"""
次のイベント情報から、開催地を都道府県レベル（または海外なら都市レベル）で1つだけ推定してください。
結果は以下のようなJSONで、"address" キーにのみ値を入れて返してください。他のテキストは不要です。

例：
- 東京のイベント → {{ "address": "東京都" }}
- パリでの出張 → {{ "address": "パリ" }}

# イベント情報
タイトル: {title}
場所: {location}

出力形式（JSONのみ）:
"""
    try:
        response = create_text(prompt)
        match = re.search(r'{\s*"address"\s*:\s*"([^"]+)"\s*}', response.text)
        if match:
            return match.group(1)
        else:
            logger.warning("Geminiの返答から住所を抽出できませんでした")
            return ""
    except Exception as e:
        logger.warning(f"Geminiによる住所推測に失敗: {e}")
        return ""
