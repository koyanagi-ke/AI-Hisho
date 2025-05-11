from lib.firestore_client import get_firestore_client, get_query_with_and_filters
import json
from datetime import datetime, timedelta, timezone
import logging

logger = logging.getLogger()


def get_records_for_day_offset(collection_name: str, offset_days: int):
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

    query = get_query_with_and_filters(db.collection("events"), filters)

    return list(query.stream())


def get_all_records():
    collection_name = "events"
    offsets = [1, 3, 5]  # 明日、3日後、5日後

    for offset in offsets:
        records = get_records_for_day_offset(collection_name, offset)
        logger.info(f"\n--- {offset}日後のレコード ---")
        for doc in records:
            logger.info(f"{doc.id}, {json.dumps(doc.to_dict())}")
