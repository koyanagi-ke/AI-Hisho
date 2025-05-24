from datetime import datetime, timedelta, timezone
import logging

from lib.firestore_client import (
    get_firestore_client,
    update_document_weather,
)
from lib.secret_manager_client import get_openweathermap_api_key
from lib.weather import fetch_weather_for_document

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


def update_weather_for_trigger_record(user_id, event_id, record_dict):
    api_key = get_openweathermap_api_key()

    JST = timezone(timedelta(hours=9))
    today = datetime.now(JST).replace(hour=0, minute=0, second=0, microsecond=0)
    target_day = today + timedelta(days=4)
    start_time = record_dict.get("start_time")
    address = record_dict.get("address")

    if (not address) and (not start_time) and (start_time <= target_day):
        forecast = fetch_weather_for_document(record_dict, api_key)
        filtered_forecast = _filter_forecast_by_dates(forecast, start_time)
        update_document_weather(
            db.collection("users").document(user_id).collection("events"),
            event_id,
            filtered_forecast,
        )
        logger.info(f"{event_id} の天気情報を更新しました")


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
