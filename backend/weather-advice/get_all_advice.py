from datetime import datetime, timedelta, timezone
import logging
import json
from lib.firestore_client import (
    get_firestore_client, 
    get_query_with_and_filters, 
    update_document_advice,
)
from lib.advice import generate_weather_advice

logger = logging.getLogger()

def _get_records_for_day_offset(collection_name: str, offset_days: int):
    JST = timezone(timedelta(hours=9))
    today = datetime.now(JST).replace(hour=0, minute=0, second=0, microsecond=0)
    target_day = today + timedelta(days=offset_days)
    start = target_day
    end = target_day + timedelta(days=1)

    db = get_firestore_client("hisho-events")
    filters = [
        ("start_time", ">=", start),
        ("start_time", "<", end),
    ]
    query = get_query_with_and_filters(db.collection_group(collection_name), filters)
    return list(query.stream())

def get_all_records():
    collection_name = "events"
    offsets = [0, 2, 4]
    all_records = []
    for offset in offsets:
        records = _get_records_for_day_offset(collection_name, offset)
        logger.info(f"--- {offset}日後のレコード ---")
        all_records.extend(records)
    return all_records

def update_advice_for_records(records):
    db = get_firestore_client("hisho-events")
    for doc in records:
        event_id = doc.id
        user_id = doc.reference.parent.parent.id
        try:
            obj = doc.to_dict()
            weather_info = obj.get("weather_info")
            schedule_info = obj.get("title")
            location = obj.get("location")
            start_time = obj.get("start_time")
            end_time = obj.get("end_time")

            if weather_info and schedule_info:
                advice = generate_weather_advice(weather_info, schedule_info, location, start_time, end_time)
                update_document_advice(
                    db.collection("users").document(user_id).collection("events"), event_id, advice
                )
                logger.info(f"{event_id} の天気アドバイスを更新しました")
            else:
                logger.info(f"{event_id} はweather_infoまたはtitle,location,timeがないためスキップ")
        except Exception as e:
            logger.error(f"{event_id} の処理でエラー発生: {e}")