import os
import json
import re
import logging
import google.generativeai as genai

from .secret_manager_client import get_gemini_api_key

logger = logging.getLogger(__name__)

genai.configure(api_key=get_gemini_api_key())
model = genai.GenerativeModel("models/gemini-2.0-flash")


def extract_json(text: str) -> dict:
    match = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", text, re.DOTALL)
    if not match:
        match = re.search(r"(\{.*?\})", text, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(1))
        except json.JSONDecodeError as e:
            logger.warning(f"JSONデコード失敗: {e}")
    return {"required": [], "optional": []}


def generate_checklist_items(
    datetime: str,
    location: str,
    description: str,
    existing_items: list[str] = None,
    weather_info: str = None,
) -> dict:
    """
    Geminiに持ち物を生成させる。
    :param datetime: イベント日時
    :param location: 開催場所
    :param description: 内容
    :param existing_items: すでにある持ち物名のリスト（省略可）
    :param is_initial: 初回生成ならTrue、追加生成ならFalse
    :return: {"required": [...], "optional": [...]}
    """
    existing_items = existing_items or []
    is_initial = not existing_items

    if is_initial:
        instruction = "必要な持ち物を『必須』と『任意』に分けて教えてください。"
    else:
        joined_items = "\\n".join(f"- {item}" for item in existing_items)
        instruction = f"""以下の持ち物はすでに考慮済みです。それ以外に必要と思われるものを『必須』と『任意』に分けて提案してください。
（既出の持ち物は絶対に含めないでください）

【すでにある持ち物】
{joined_items}
"""

    if weather_info:
        weather_section = f"また、次のような天気予報情報があります。持ち物の判断に考慮してください：\n{weather_info}\n"
    else:
        weather_section = ""

    prompt = f"""
次のスケジュールに向けて、{instruction}
{weather_section}
それぞれの持ち物について、何日前から準備すべきかも整数で指定してください。

出力はJSON形式のみでお願いします（説明文なし）:
{{
  "required": [
    {{ "item": "持ち物名", "prepare_before": 日数 }}
  ],
  "optional": [
    {{ "item": "持ち物名", "prepare_before": 日数 }}
  ]
}}

日時: {datetime}
場所: {location}
内容: {description}
"""

    response = model.generate_content(prompt)
    logger.info(f"Gemini応答: {response.text}")
    return extract_json(response.text)
