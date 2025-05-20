from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import logging
from datetime import datetime, timezone, timedelta
from lib.firestore_client import (
    get_firestore_client,
    get_user_events_collection,
    get_query_with_and_filters,
)
from lib.user_context import get_user_id_from_request
from lib.http_utils import respond
from lib.logger_setup import configure_logger
from lib.firestore_utils import serialize_firestore_dict
from lib.notify import notify_all_users


configure_logger()
logger = logging.getLogger(__name__)
db = get_firestore_client("hisho-events")
JST = timezone(timedelta(hours=9))


class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        logger.info(f"GETリクエスト受信: パス={self.path}、ヘッダー={self.headers}")
        try:
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

            respond(self, 200, result)

        except Exception as e:
            logger.exception("GET失敗")
            respond(self, 500, {"error": str(e)})

    def do_POST(self):
        logger.info(f"Cloud Scheduler POSTバッチ開始")
        try:
            result = notify_all_users()
            respond(self, 200, result)
        except Exception as e:
            logger.exception("バッチ失敗")
            respond(self, 500, {"error": str(e)})


def run():
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("", port), RequestHandler)
    logger.info(f"サーバー起動 ポート: {port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
