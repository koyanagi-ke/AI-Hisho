from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import logging
from datetime import datetime, timezone, timedelta
from urllib.parse import urlparse, parse_qs
from lib.firestore_client import (
    get_user_event_doc,
    get_firestore_client,
    get_event_checklist_collection,
    get_user_events_collection,
)
from lib.user_context import get_user_id_from_request
from lib.http_utils import parse_json_body, respond
from lib.logger_setup import configure_logger
from lib.validators import validate_and_convert_event_data
from lib.firestore_utils import serialize_firestore_dict
from lib.gemini_client import infer_address_from_title_and_location
from lib.exceptions import ValidationError


configure_logger()
logger = logging.getLogger(__name__)
db = get_firestore_client("hisho-events")
JST = timezone(timedelta(hours=9))


class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        logger.info(f"GETリクエスト受信")
        try:
            user_id = get_user_id_from_request(self.headers)
            query = parse_qs(urlparse(self.path).query)
            event_id = query.get("event_id", [None])[0]
            if not event_id:
                respond(self, 400, {"error": "event_id は必須です"})
                return

            event_ref = get_user_event_doc(db, user_id, event_id)
            doc = event_ref.get()
            if not doc.exists:
                respond(self, 404, {"error": "event not found"})
                return
            event = {"id": doc.id, **serialize_firestore_dict(doc.to_dict())}

            # チェックリストを取得
            checklist_ref = get_event_checklist_collection(db, user_id, event_id)
            checklists = []
            for item in checklist_ref.stream():
                checklist_data = serialize_firestore_dict(item.to_dict())
                checklist_data["id"] = item.id
                checklists.append(checklist_data)

            event["checklists"] = checklists
            respond(self, body=event)

        except Exception as e:
            logger.exception("GET失敗")
            respond(self, 500, {"error": str(e)})

    def do_POST(self):
        logger.info(f"POSTリクエスト受信")
        try:
            user_id = get_user_id_from_request(self.headers)
            data = parse_json_body(self)

            data = validate_and_convert_event_data(data)

            if "address" not in data or not data["address"]:
                title = data.get("title", "")
                location = data.get("location", "")
                inferred = infer_address_from_title_and_location(title, location)
                if inferred:
                    data["address"] = inferred

            data["notification_sented"] = False

            event_ref = get_user_events_collection(db, user_id).document()
            event_ref.set(data)
            respond(self, 200, {"id": event_ref.id})
        except ValidationError as ve:
            logger.warning(f"⚠️ Validation failed: {ve}")
            respond(self, status=400, body={"error": str(ve)})
        except Exception as e:
            logger.exception("POST失敗")
            respond(self, 500, {"error": str(e)})

    def do_PUT(self):
        logger.info(f"PUTリクエスト受信")
        try:
            user_id = get_user_id_from_request(self.headers)
            data = parse_json_body(self)
            event_id = data.get("id")
            if not event_id:
                respond(self, 400, "event ID が必要です")
                return

            # idを取り除いてバリデーション
            data_for_update = {k: v for k, v in data.items() if k != "id"}

            data_for_update = validate_and_convert_event_data(
                data_for_update, is_update=True
            )
            event_ref = get_user_event_doc(db, user_id, event_id)
            if not event_ref.get().exists:
                respond(self, 404, {"error": "event not found"})
                return
            event_ref.update(data_for_update)
            respond(self, 200, {"status": "updated"})
        except ValidationError as ve:
            logger.warning(f"⚠️ Validation failed: {ve}")
            respond(self, status=400, body={"error": str(ve)})
        except Exception as e:
            logger.exception("PUT失敗")
            respond(self, 500, {"error": str(e)})

    def do_DELETE(self):
        logger.info(f"DELETEリクエスト受信")
        try:
            user_id = get_user_id_from_request(self.headers)
            data = parse_json_body(self)
            event_id = data.get("id")
            if not event_id:
                respond(self, 400, "event ID が必要です")
                return

            event_ref = get_user_event_doc(db, user_id, event_id)
            if not event_ref.get().exists:
                respond(self, 404, {"error": "event not found"})
                return

            checklist_collection = get_event_checklist_collection(db, user_id, event_id)

            # チェックリストのサブコレクションを明示的に削除
            checklist_docs = checklist_collection.stream()
            for doc in checklist_docs:
                doc.reference.delete()

            # イベント本体のドキュメントを削除
            event_ref.delete()
            respond(self, 200, {"status": "deleted"})
        except Exception as e:
            logger.exception("DELETE失敗")
            respond(self, 500, {"error": str(e)})


def run():
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("", port), RequestHandler)
    logger.info(f"サーバー起動 ポート: {port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
