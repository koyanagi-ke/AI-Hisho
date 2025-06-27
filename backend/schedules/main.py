from http.server import BaseHTTPRequestHandler, HTTPServer
import logging
import os
import json
import google.cloud.firestore
from datetime import datetime, timezone, timedelta

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


JST = timezone(timedelta(hours=9))


def to_iso(dt):
    # Firestore Timestamp型やdatetime型をISO8601文字列に変換
    if hasattr(dt, "isoformat"):
        return dt.isoformat()
    try:
        # google.cloud.firestore_v1._helpers.Timestampの場合
        return dt.ToDatetime().isoformat()
    except Exception:
        return str(dt)


def parse_datetime_field(value: str) -> datetime:
    """ISO形式の日時文字列をdatetime型に変換（JSTに補正）"""
    if value.endswith("Z"):
        # ZはUTCを示す → JSTに変換
        dt = datetime.fromisoformat(value.replace("Z", "+00:00"))
        return dt.astimezone(JST)
    else:
        dt = datetime.fromisoformat(value)
        # タイムゾーンがなければ JST を付ける
        return dt if dt.tzinfo else dt.replace(tzinfo=JST)


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
            start_time = parse_datetime_field(body.get("start_time"))
            end_time = parse_datetime_field(body.get("end_time"))
            logger.info(start_time)
            logger.info(end_time)

            # DB検索
            records = get_schedules_by_user_and_period(user_id, start_time, end_time)

            result = []
            for rec in records:
                item = {
                    "event_id": rec.get("id"),
                    "title": rec.get("title"),
                    "start_time": to_iso(rec.get("start_time")),
                    "end_time": to_iso(rec.get("end_time")),
                    "location": rec.get("location"),
                    "notify_at": to_iso(rec.get("notify_at")),
                    "address": rec.get("address"),
                }
                result.append(item)

            # レスポンス
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
