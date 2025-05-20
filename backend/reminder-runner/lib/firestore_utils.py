from datetime import datetime, timezone, timedelta
from google.cloud.firestore_v1 import DocumentReference, GeoPoint

JST = timezone(timedelta(hours=9))


def serialize_firestore_dict(doc: dict) -> dict:
    result = {}
    for k, v in doc.items():
        if isinstance(v, datetime):
            result[k] = v.astimezone(JST).isoformat()
        elif isinstance(v, GeoPoint):
            result[k] = {"lat": v.latitude, "lng": v.longitude}
        elif isinstance(v, DocumentReference):
            result[k] = v.path
        else:
            result[k] = v
    return result
