import logging
from lib.firestore_client import get_firestore_client, update_document_advice
from lib.advice import generate_weather_advice

logger = logging.getLogger()
db = get_firestore_client("hisho-events")

def _get_record_dict(event_ref):
    event_doc = event_ref.get()
    event = event_doc.to_dict()
    return event

def get_trigger_record(user_id, event_id):
    event_ref = (
        db.collection("users").document(user_id).collection("events").document(event_id)
    )
    if not event_ref.get().exists:
        raise ValueError(f"イベントが存在しません: userId:{user_id}, eventId{event_id}")
    record_dict = _get_record_dict(event_ref)
    return record_dict

def update_advice_for_trigger_record(user_id, event_id, record_dict):
    weather_info = record_dict.get("weather_info")
    schedule_info = record_dict.get("schedule_info")
    if weather_info and schedule_info:
        advice = generate_weather_advice(weather_info, schedule_info)
        update_document_advice(
            db.collection("users").document(user_id).collection("events"),
            event_id,
            advice,
        )
        logger.info(f"{event_id} の天気アドバイスを更新しました")
    else:
        logger.info("weather_infoまたはschedule_infoが空のためアドバイス生成をスキップ")