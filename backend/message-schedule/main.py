from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import logging
from datetime import datetime, timezone, timedelta

from lib.logger_setup import configure_logger
from lib.http_utils import parse_json_body, respond
from lib.validators import validate_exact_fields, validate_schedule_request
from lib.gemini_client import extract_event_schedule, extract_json
from lib.exceptions import ValidationError

# JST定義
JST = timezone(timedelta(hours=9))

# ログ設定
configure_logger()
logger = logging.getLogger(__name__)


class RequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        try:
            data = parse_json_body(self)
            validate_exact_fields(data, ["message"])
            validate_schedule_request(data)

            messages = data["message"]

            result = extract_event_schedule(messages)

            respond(self, status=200, body=result)

        except ValidationError as ve:
            logger.warning(f"⚠️ Validation error: {ve}")
            respond(self, status=400, body={"error": str(ve)})

        except Exception as e:
            logger.exception("❌ Unexpected server error")
            respond(self, status=500, body={"error": "Internal server error"})


def run():
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("", port), RequestHandler)
    logger.info(f"サーバー起動 ポート: {port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
