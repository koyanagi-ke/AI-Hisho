from http.server import BaseHTTPRequestHandler, HTTPServer
import logging
import os
import json
import google.cloud.firestore
from datetime import datetime

from user_context import get_user_id_from_request
from http_utils import parse_json_body
from db_access import get_schedules_by_user_and_period 

# ロガーインスタンス作成
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# 標準出力にログを出すハンドラー
handler = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)

def to_iso(dt):
    # Firestore Timestamp型やdatetime型をISO8601文字列に変換
    if hasattr(dt, "isoformat"):
        return dt.isoformat()
    try:
        # google.cloud.firestore_v1._helpers.Timestampの場合
        return dt.ToDatetime().isoformat()
    except Exception:
        return str(dt)

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        logger.info(f"リクエスト受信: パス={self.path}、ヘッダー={self.headers}")

        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(b"OK")

    def do_POST(self):
        try:
            user_id = get_user_id_from_request(self.headers)

            body = parse_json_body(self)
            start_time = datetime.fromisoformat(body.get("start_time"))
            end_time = datetime.fromisoformat(body.get("end_time"))

            # DB検索
            records = get_schedules_by_user_and_period(user_id, start_time, end_time)

            result = []
            for rec in records:
                item = {
                    "title": rec.get("title"),
                    "start_time": to_iso(rec.get("start_time")),
                    "end_time": to_iso(rec.get("end_time")),
                    "location": rec.get("location"),
                }
                result.append(item)

            #レスポンス
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(result).encode("utf-8"))
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
