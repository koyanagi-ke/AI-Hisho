from datetime import datetime
from google.cloud.firestore_v1 import DocumentReference, GeoPoint


def serialize_firestore_dict(doc: dict) -> dict:
    result = {}
    for k, v in doc.items():
        if isinstance(v, datetime):
            result[k] = v.isoformat()
        elif isinstance(v, GeoPoint):
            result[k] = {"lat": v.latitude, "lng": v.longitude}
        elif isinstance(v, DocumentReference):
            result[k] = v.path
        else:
            result[k] = v
    return result
