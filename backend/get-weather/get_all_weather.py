from datetime import datetime, timedelta, timezone
import json
import logging

from lib.firestore_client import (
    get_firestore_client,
    get_query_with_and_filters,
    update_document_weather,
)
from lib.secret_manager_client import get_openweathermap_api_key
from lib.weather import fetch_weather_for_document

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

    query = get_query_with_and_filters(db.collection(collection_name), filters)

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


def update_weather_for_records(records, collection_name: str = "events"):
    api_key = get_openweathermap_api_key()

    db = get_firestore_client("hisho-events")

    for doc in records:
        doc_id = doc.id
        try:
            forecast = fetch_weather_for_document(doc.to_dict(), api_key)
            start_time = doc.to_dict().get("start_time")
            filtered_forecast = _filter_forecast_by_dates(forecast, start_time)
            update_document_weather(
                db.collection(collection_name), doc_id, filtered_forecast
            )
            logger.info(f"{doc_id} の天気情報を更新しました")
        except Exception as e:
            logger.error(f"{doc_id} の処理でエラー発生: {e}")


def _filter_forecast_by_dates(forecast: dict, start_time: datetime):
    # 対象日（前日と当日）
    target_dates = {(start_time - timedelta(days=1)).date(), start_time.date()}

    filtered_list = [
        entry
        for entry in forecast.get("list", [])
        if "dt_txt" in entry
        and datetime.strptime(entry["dt_txt"], "%Y-%m-%d %H:%M:%S").date()
        in target_dates
    ]

    # city情報はそのまま保持して、listだけ絞る
    return {"city": forecast.get("city"), "list": filtered_list}
