from http.server import BaseHTTPRequestHandler, HTTPServer
import logging
import os
import json
from lib.logger_setup import configure_logger
from get_all_advice import get_all_records, update_advice_for_records
from get_trigger_advice import get_trigger_record, update_advice_for_trigger_record
import google.generativeai as genai
from lib.secret_manager_client import get_gemini_api_key

configure_logger()
logger = logging.getLogger()

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
        logger.info(f"dailyバッチによるPUTリクエスト受信")
        records = get_all_records()
        update_advice_for_records(records)
        logger.info("正常終了")

        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(b"PUT OK")

    def do_PATCH(self):
        content_length = int(self.headers.get("Content-Length", 0))
        patch_data = self.rfile.read(content_length)
        logger.info(
            f"PATCHリクエスト受信: パス={self.path}、ヘッダー={self.headers}、ボディ={patch_data.decode('utf-8')}"
        )

        try:
            data = json.loads(patch_data)
            user_id = data.get("userId")
            event_id = data.get("eventId")
            if not user_id:
                raise ValueError("userIdが必要です")
            if not event_id:
                raise ValueError("eventIdが必要です")
            record = get_trigger_record(user_id, event_id)
            update_advice_for_trigger_record(user_id, event_id, record)
            logger.info("正常終了")
        except Exception as e:
            logger.error(f"エラー発生：{str(e)}")

        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(json.dumps({"status": "success"}).encode("utf-8"))


def run():
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("", port), RequestHandler)
    logger.info(f"サーバー起動 ポート: {port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
