import logging
from datetime import datetime, timezone, timedelta
from firebase_admin import messaging
from lib.firestore_client import (
    get_firestore_client,
    get_user_events_collection,
    get_query_with_and_filters,
)
from lib.user_context import get_user_id_from_request
from lib.firestore_utils import serialize_firestore_dict
from lib.firebase_auth import firebase_configure


logger = logging.getLogger(__name__)
db = get_firestore_client("hisho-events")
JST = timezone(timedelta(hours=9))


def get_checklist_reminder(self):
    user_id = get_user_id_from_request(self.headers)
    today = datetime.now(JST).replace(hour=0, minute=0, second=0, microsecond=0)

    query = get_query_with_and_filters(
        get_user_events_collection(db, user_id),
        [
            ("next_check_due", "<=", today),
            ("start_time", ">=", today),
        ],
    )

    result = []
    for event_doc in query.stream():
        event = serialize_firestore_dict(event_doc.to_dict())
        result.append(
            {
                "event_id": event_doc.id,
                "title": event.get("title"),
                "start_time": event.get("start_time"),
                "end_time": event.get("end_time"),
            }
        )
    return result


def post_checklist_reminder():
    firebase_configure()

    today = datetime.now(JST).replace(hour=0, minute=0, second=0, microsecond=0)
    users_ref = db.collection("users")
    success_count = 0
    fail_count = 0

    for user_doc in users_ref.stream():
        user_id = user_doc.id
        user_data = user_doc.to_dict()
        tokens = user_data.get("fcm_tokens", [])
        if not tokens:
            continue

        events = _get_pending_events(user_id, today)
        if not events:
            continue

        tokens, success, fail = _send_fcm(user_id, tokens, events)
        success_count += success
        fail_count += fail

        if tokens is not None:
            users_ref.document(user_id).update({"fcm_tokens": tokens})

    return {"status": "push completed", "success": success_count, "fail": fail_count}


def _get_pending_events(user_id: str, today: datetime):
    event_query = get_query_with_and_filters(
        get_user_events_collection(db, user_id),
        [
            ("next_check_due", "<=", today),
            ("start_time", ">=", today),
        ],
    )
    return [serialize_firestore_dict(doc.to_dict()) for doc in event_query.stream()]


def _send_fcm(user_id: str, tokens: list[str], events: list[dict]):
    body = "\n".join([f"・{e['title']}（{e['start_time'][:10]}）" for e in events])
    notification = messaging.Notification(
        title="持ち物の準備を忘れずに 📦",
        body=f"今日から準備すべき予定があります:\n{body}",
    )
    message = messaging.MulticastMessage(notification=notification, tokens=tokens)

    response = messaging.send_multicast(message)
    logger.info(
        f"[{user_id}] 成功={response.success_count}, 失敗={response.failure_count}"
    )

    if response.failure_count == 0:
        return tokens, response.success_count, 0

    invalid = [
        tokens[i]
        for i, r in enumerate(response.responses)
        if not r.success
        and hasattr(r.exception, "code")
        and r.exception.code == "messaging/registration-token-not-registered"
    ]
    updated_tokens = [t for t in tokens if t not in invalid]
    if invalid:
        logger.info(f"[{user_id}] 無効トークン削除: {len(invalid)} 件")

    return updated_tokens, response.success_count, response.failure_count
