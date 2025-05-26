import google.cloud.firestore
from google.cloud.firestore_v1.base_query import FieldFilter, BaseCompositeFilter

def get_schedules_by_user_and_period(user_id, start_time, end_time):
    db = google.cloud.firestore.Client()
    collection = db.collection('users').document(user_id).collection('events')
    
    filters = [
        ("start_time", ">=", start_time),
        ("start_time", "<", end_time),
    ]

    field_filters = [FieldFilter(field, op, val) for field, op, val in filters]
    result = collection.where(filter=BaseCompositeFilter("AND", field_filters)).order_by("start_time").stream()

    return result