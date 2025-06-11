import requests
from google import genai
from .secret_manager_client import get_gemini_api_key
import logging

logger = logging.getLogger()

get_gemini_api_key()
client = genai.Client()
model = "gemini-2.0-flash"

def build_prompt(weather_info, schedule_info, location, start_time, end_time):
    """
    天気情報とスケジュール情報をもとにGeminiへ投げるプロンプトを組み立てる
    """
    prompt = (
        "あなたは予定プランナーです。"
        "次のスケジュールと天気情報を考慮して、当日を楽しめるよう日本語で2〜3文程度のアドバイスを作成してください。\n"
        f"【スケジュール情報】\n{schedule_info}\n"
        f"【天気情報】\n{weather_info}\n"
        f"【場所】\n{location}\n"
        f"【開始時間】\n{start_time}\n"
        f"【終了時間】\n{end_time}\n"
        "【出力例】\n・雨が強すぎるので、水族館や映画館に行くのはいかがでしょうか。\n"
        "・絶好の動物園日和ですね。日焼け対策と水分補給を忘れずに。\n"
        "・雨の可能性が高いので、降りだしたら近くの〇〇カフェで雨宿りするのがおすすめです。\n"
    )
    return prompt

def generate_weather_advice(weather_info, schedule_info, location, start_time, end_time):
    """
    天気情報+スケジュール情報からGemini APIを呼び出してアドバイスを生成
    """

    prompt = build_prompt(weather_info, schedule_info, location, start_time, end_time)

    try:
        response = client.models.generate_content(
            model=model, contents=prompt
        )

        if response.text:
            advice = response.text.strip()
            return advice if advice else "天気アドバイスを取得できませんでした（空の応答）"
        else:
            return f"天気アドバイスを取得できませんでした。理由: {response.prompt_feedback if response.prompt_feedback else '不明な理由'}"

    except Exception as e:
        logger.error(f"Gemini API error (SDK): {e}")
        return "天気アドバイス生成に失敗しました"