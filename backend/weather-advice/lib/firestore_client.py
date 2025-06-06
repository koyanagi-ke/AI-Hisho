def update_document_advice(events_collection_ref, event_id, advice):
    # Firestoreの該当ドキュメントにweather_adviceを書き込む
    events_collection_ref.document(event_id).update({"weather_advice": advice})