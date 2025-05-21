import logging
from datetime import datetime, timezone, timedelta
from firebase_admin import messaging
from lib.firestore_client import (
    get_firestore_client,
    get_user_events_collection,
    get_query_with_and_filters,
)
from lib.firestore_utils import serialize_firestore_dict
from lib.firebase_auth import firebase_configure


logger = logging.getLogger(__name__)
db = get_firestore_client("hisho-events")
JST = timezone(timedelta(hours=9))


def post_schedule_reminder():
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

        events_dict, events = _get_pending_events(user_id, today)
        if not events_dict:
            continue

        tokens, success, fail = _send_fcm(user_id, tokens, events_dict, events)
        success_count += success
        fail_count += fail

        if tokens is not None:
            users_ref.document(user_id).update({"fcm_tokens": tokens})

    return {"status": "push completed", "success": success_count, "fail": fail_count}


def _get_pending_events(user_id: str, today: datetime):
    events = get_query_with_and_filters(
        get_user_events_collection(db, user_id),
        [
            ("notification_sented", "==", False),
            ("notify_at", "<=", today),
        ],
    ).stream()
    return [serialize_firestore_dict(doc.to_dict()) for doc in events], events


def _send_fcm(user_id: str, tokens: list[str], events_dict: list[dict], events: list):
    body = "\n".join([f"・{e['title']}（{e['start_time'][:10]}）" for e in events_dict])
    notification = messaging.Notification(
        title="予定の通知 ✅️",
        body=f"直近の予定をお送りします:\n{body}",
    )
    message = messaging.MulticastMessage(notification=notification, tokens=tokens)

    response = messaging.send_multicast(message)
    logger.info(
        f"[{user_id}] 成功={response.success_count}, 失敗={response.failure_count}"
    )

    for event in events:
        event.reference.update({"notification_sented": True})

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
