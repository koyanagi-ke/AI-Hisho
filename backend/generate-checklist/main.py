from http.server import BaseHTTPRequestHandler, HTTPServer
import logging
import os
import json

from lib.logger_setup import configure_logger
from lib.firestore_client import get_firestore_client
from lib.gemini_client import generate_checklist_items

configure_logger()
logger = logging.getLogger(__name__)
db = get_firestore_client("hisho-events")


class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        logger.info(f"リクエスト受信: パス={self.path}、ヘッダー={self.headers}")

        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(b"OK")

    def do_POST(self):
        content_length = int(self.headers.get("Content-Length", 0))
        post_data = self.rfile.read(content_length)

        logger.info(
            f"POSTリクエスト受信: パス={self.path}、ヘッダー={self.headers}、ボディ={post_data.decode('utf-8')}"
        )

        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(b"OK")

    def do_PUT(self):
        content_length = int(self.headers.get("Content-Length", 0))
        put_data = self.rfile.read(content_length)

        logger.info(
            f"PUTリクエスト受信: パス={self.path}、ヘッダー={self.headers}、ボディ={put_data.decode('utf-8')}"
        )

        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(b"PUT OK")

    def do_PATCH(self):
        content_length = int(self.headers.get("Content-Length", 0))
        patch_data = self.rfile.read(content_length).decode("utf-8")
        logger.info(f"PATCH受信: {patch_data}")

        try:
            data = json.loads(patch_data)
            user_id = data.get("userId")
            event_id = data.get("eventId")
            if not user_id:
                raise ValueError("userIdが必要です")
            if not event_id:
                raise ValueError("eventIdが必要です")

            event_ref = (
                db.collection("users")
                .document(user_id)
                .collection("events")
                .document(event_id)
            )
            event_doc = event_ref.get()
            if not event_doc.exists:
                raise ValueError(
                    f"イベントが存在しません: userId:{user_id}, eventId{event_id}"
                )

            event = event_doc.to_dict()
            datetime = event.get("start_time", "")
            location = event.get("location", "")
            description = event.get("title", "")

            checklist_ref = event_ref.collection("checklists")
            weather_info = event.get("weather_info")

            result = generate_checklist_items(
                datetime, location, description, weather_info=weather_info
            )

            for category in ["required", "optional"]:
                for item in result.get(category, []):
                    checklist_ref.document().set(
                        {
                            "item": item.get("item"),
                            "prepare_before": item.get("prepare_before", 0),
                            "required": category == "required",
                            "checked": False,
                        }
                    )

            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "success"}).encode("utf-8"))

        except Exception as e:
            logger.exception("エラー発生")
            self.send_response(500)
            self.end_headers()
            self.wfile.write(f"Error: {str(e)}".encode("utf-8"))


def run():
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("", port), RequestHandler)
    logger.info(f"サーバー起動 ポート: {port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
