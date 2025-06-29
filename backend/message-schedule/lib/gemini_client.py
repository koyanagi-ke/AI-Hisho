import re
import logging
from google import genai
import tiktoken
import json
from datetime import datetime, timezone, timedelta
from .secret_manager_client import get_gemini_api_key

logger = logging.getLogger(__name__)

get_gemini_api_key()
client = genai.Client()
model = "gemini-2.0-flash"
JST = timezone(timedelta(hours=9))

MAX_TOKENS = 1048576
RESERVED_TOKENS = 2500  # システム文 + 生成余地を残す


def create_text(contents, model=model):
    response = client.models.generate_content(model=model, contents=contents)
    return response


def extract_json(text: str) -> dict:
    logger.info(text)
    match = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", text, re.DOTALL)
    if not match:
        match = re.search(r"(\{.*?\})", text, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(1))
        except json.JSONDecodeError as e:
            logger.warning(f"JSONデコード失敗: {e}")
    return {"required": [], "optional": []}


def extract_event_schedule(chat_history: list[dict]) -> dict:
    """
    チャット履歴から、予定のタイトル・日時・場所を抽出する。
    :param chat_history: [{ "role": "user|model", "text": "..." }]
    :return: {
      "title": "イベント名",
      "start_time": "ISO8601形式（JST）",
      "end_time": "ISO8601形式（JST）",
      "location": "場所"
    }
    """
    now = datetime.now(JST)
    today_str = now.strftime("%Y-%m-%d")
    weekday_jp = ["月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日", "日曜日"][
        now.weekday()
    ]

    trimmed_history, user_or_model = truncate_chat_history(chat_history)

    system_instruction = f"""今日は {today_str}（{weekday_jp}）です。

以下は{user_or_model}のやりとりの履歴です。user同士の可能性もあれば、userとmodelでやり取りをしている可能性もあります。
この会話の中で、予定されているイベントがある場合は、以下の情報を抽出してください：

- イベントのタイトル（自然な日本語で簡潔に）
- 開始日時（JSTで、ISO 8601形式で）
- 終了日時（JSTで、ISO 8601形式で）
- 場所（できるだけ具体的に）

【出力形式】
※以下はあくまで構造の例です。日付や時刻は、会話の内容に基づいて正しく推論してください。説明文や補足は一切不要です。必ず次のようなJSONのみを返してください：

{{
  "title": "イベントのタイトル",
  "start_time": "2025-06-01T09:00:00+09:00",
  "end_time": "2025-06-01T14:00:00+09:00",
  "location": "イベントの場所"
}}
"""

    prompt = [
        {"role": "user", "parts": [{"text": system_instruction}]},
        *trimmed_history,
    ]

    response = create_text(prompt)
    return extract_json(response.text)


def estimate_tokens(text: str) -> int:
    # GPT-4系互換の推定器（tiktoken使用例、環境によっては google.generativeai の token_count を使ってください）
    encoding = tiktoken.get_encoding("cl100k_base")
    return len(encoding.encode(text))


def truncate_chat_history(chat_history: list[dict]) -> list[dict]:
    total_tokens = 0
    result = []
    user_or_model = "user同士"

    # 最新の発言から逆順で追加（古いものを切る）
    for message in reversed(chat_history):
        message_tokens = sum(
            estimate_tokens(part.get("text", "")) for part in message.get("parts", [])
        )
        if total_tokens + message_tokens > MAX_TOKENS - RESERVED_TOKENS:
            break
        result.insert(0, message)
        total_tokens += message_tokens
        if message.get("role") == "model":
            user_or_model = "userとmodel(gemini)と"

    return result, user_or_model
