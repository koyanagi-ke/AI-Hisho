from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import logging

from lib.http_utils import respond
from lib.logger_setup import configure_logger

from checklist_reminder import get_checklist_reminder, post_checklist_reminder
from schedule_reminder import post_schedule_reminder

configure_logger()
logger = logging.getLogger(__name__)


class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        logger.info(f"GETリクエスト受信: パス={self.path}、ヘッダー={self.headers}")
        try:
            result = get_checklist_reminder(self)
            respond(self, 200, result)

        except Exception as e:
            logger.exception("GET失敗")
            respond(self, 500, {"error": str(e)})

    def do_POST(self):
        logger.info(f"Cloud Scheduler 持ち物リマインダーバッチ開始")
        try:
            result = post_checklist_reminder()
            respond(self, 200, result)
        except Exception as e:
            logger.exception("持ち物リマインダーバッチ失敗")
            respond(self, 500, {"error": str(e)})

    def do_PUT(self):
        logger.info(f"Cloud Scheduler スケジュールリマインダーバッチ開始")
        try:
            result = post_schedule_reminder()
            respond(self, 200, result)
        except Exception as e:
            logger.exception("スケジュールリマインダーバッチ失敗")
            respond(self, 500, {"error": str(e)})


def run():
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("", port), RequestHandler)
    logger.info(f"サーバー起動 ポート: {port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
