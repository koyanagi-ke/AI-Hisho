from http.server import BaseHTTPRequestHandler, HTTPServer
import logging
import os
import json

from .user_context import get_user_id_from_request
from .http_utils import parse_json_body
from .schedule_service import fetch_schedules, format_schedules

# ロガーインスタンス作成
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# 標準出力にログを出すハンドラー
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)


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

        try:
            user_id = get_user_id_from_request(self.headers)
            logger.info(f"user_id取得成功: {user_id}")

            body = parse_json_body(self)
            logger.info(f"リクエストボディ: {body}")
            start_time = body.get("start_time")
            end_time = body.get("end_time")

            if start_time and end_time:
                records = fetch_schedules(user_id, start_time, end_time)
            else:
                records = fetch_schedules(user_id)  # 期間指定なし＝全件

            logger.info(f"スケジュール取得結果: {records}")
            result = format_schedules(records)
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b"OK")
        except Exception as e:
            logger.error(f"エラー発生: {e}")
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))


def run():
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("", port), RequestHandler)
    logger.info(f"サーバー起動 ポート: {port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
