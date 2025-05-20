from http.server import BaseHTTPRequestHandler, HTTPServer
import logging
import os
from lib.logger_setup import configure_logger
from lib.firestore_client import (
    get_firestore_client,
)
from lib.user_context import get_user_id_from_request
from lib.http_utils import parse_json_body, respond

configure_logger()
logger = logging.getLogger(__name__)
db = get_firestore_client("hisho-events")


class RequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        try:
            user_id = get_user_id_from_request(self.headers)
            body = parse_json_body(self)
            fcm_token = body.get("fcm_token")
            if not fcm_token:
                raise ValueError("fcm_token は必須です")

            user_ref = db.collection("users").document(user_id)
            user_doc = user_ref.get()
            if not user_doc.exists:
                user_ref.set({"fcm_tokens": [fcm_token]})
                logger.info(f"[{user_id}] FCMトークンを新規ユーザーとして作成")
            else:
                user_data = user_doc.to_dict()
                existing_tokens = user_data.get("fcm_tokens", [])

                if fcm_token not in existing_tokens:
                    updated_tokens = existing_tokens + [fcm_token]
                    user_ref.update({"fcm_tokens": updated_tokens})
                    logger.info(f"FCMトークン追加: user={user_id}")

            respond(self, 200, {"status": "ok"})

        except Exception as e:
            logger.exception("FCMトークン登録失敗")
            respond(self, 500, {"error": str(e)})


def run():
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("", port), RequestHandler)
    logger.info(f"サーバー起動 ポート: {port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
