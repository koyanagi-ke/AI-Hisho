# firestore_client.py
from google.cloud import firestore
from google.cloud.firestore_v1.base_query import FieldFilter, BaseCompositeFilter


def get_firestore_client(database_name: str = "(default)"):
    return firestore.Client(database=database_name)


def get_query_with_and_filters(collection, filters):
    field_filters = [FieldFilter(field, op, val) for field, op, val in filters]
    return collection.where(filter=BaseCompositeFilter("AND", field_filters))


def get_query_with_or_filters(collection, filters):
    field_filters = [FieldFilter(field, op, val) for field, op, val in filters]
    return collection.where(filter=BaseCompositeFilter("OR", field_filters))


# 単一イベントのドキュメント参照
def get_user_event_doc(db, user_id: str, event_id: str):
    return (
        db.collection("users").document(user_id).collection("events").document(event_id)
    )


# ユーザーのイベントコレクション参照
def get_user_events_collection(db, user_id: str):
    return db.collection("users").document(user_id).collection("events")


# チェックリストのコレクション参照
def get_event_checklist_collection(db, user_id: str, event_id: str):
    return get_user_event_doc(db, user_id, event_id).collection("checklists")


# 単一チェックリスト項目のドキュメント参照
def get_event_checklist_item(db, user_id: str, event_id: str, item_id: str):
    return get_event_checklist_collection(db, user_id, event_id).document(item_id)
