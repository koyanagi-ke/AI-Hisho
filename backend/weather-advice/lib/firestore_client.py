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

def update_document_advice(collection, doc_id: str, advice: str):
    collection.document(doc_id).update({"weather_advice": advice})