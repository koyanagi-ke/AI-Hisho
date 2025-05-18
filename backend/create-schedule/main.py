from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import logging
from datetime import datetime, timezone, timedelta
from urllib.parse import urlparse, parse_qs
from lib.firestore_client import get_user_event_ref, get_firestore_client
from lib.user_context import get_user_id_from_request
from lib.http_utils import parse_json_body, respond
from lib.logger_setup import configure_logger
from lib.validators import validate_and_convert_event_data


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

            if event_id:
                event_ref = get_user_event_ref(db, user_id, event_id)
                doc = event_ref.get()
                if not doc.exists:
                    respond(self, 404, {"error": "event not found"})
                    return
                event = {"id": doc.id, **doc.to_dict()}
                respond(self, body=event)
            else:
                events_ref = get_user_event_ref(db, user_id)
                events = [
                    {"id": doc.id, **doc.to_dict()} for doc in events_ref.stream()
                ]
                respond(self, body=events)
        except Exception as e:
            logger.exception("GET失敗")
            respond(self, 500, {"error": str(e)})

    def do_POST(self):
        logger.info(f"POSTリクエスト受信")
        try:
            user_id = get_user_id_from_request(self.headers)
            data = parse_json_body(self)

            data = validate_and_convert_event_data(data)

            data["notification_sented"] = False

            event_ref = get_user_event_ref(db, user_id).document()
            event_ref.set(data)
            respond(self, 200, {"id": event_ref.id})
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
                raise ValueError("event ID が必要です")

            data = validate_and_convert_event_data(data)
            event_ref = get_user_event_ref(db, user_id, event_id)
            event_ref.update(data)
            respond(self, 200, {"status": "updated"})
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
                raise ValueError("event ID が必要です")

            event_ref = get_user_event_ref(db, user_id, event_id)
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
