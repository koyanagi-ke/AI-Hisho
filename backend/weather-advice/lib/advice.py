import requests
import google.generativeai as genai

def build_prompt(weather_info, schedule_info):
    """
    天気情報とスケジュール情報をもとにGeminiへ投げるプロンプトを組み立てる
    """
    prompt = (
        "あなたは気象アドバイザーです。"
        "次のスケジュールと天気情報を参考に、当日の注意点やアドバイスを日本語で1つ短く作ってください。\n"
        f"【スケジュール情報】\n{schedule_info}\n"
        f"【天気情報】\n{weather_info}\n"
        "【出力例】\n・雨の予報ですので傘をお忘れなく。\n"
        "・気温が高いので熱中症対策を忘れずに。\n"
    )
    return prompt

def generate_weather_advice(weather_info, schedule_info):
    """
    天気情報+スケジュール情報からGemini APIを呼び出してアドバイスを生成
    """

    prompt = build_prompt(weather_info, schedule_info)

    try:
        model = genai.GenerativeModel(
            model_name="gemini-2.0-flash",
            generation_config={ 
                "temperature": 0.7,
                "max_output_tokens": 200,
            }
        )

        response = model.generate_content(prompt)

        if response.parts:
            advice = response.text.strip()
            return advice if advice else "天気アドバイスを取得できませんでした（空の応答）"
        else:
            return f"天気アドバイスを取得できませんでした。理由: {response.prompt_feedback if response.prompt_feedback else '不明な理由'}"

    except Exception as e:
        print(f"Gemini API error (SDK): {e}")
        return "天気アドバイス生成に失敗しました"