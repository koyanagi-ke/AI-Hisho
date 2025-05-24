from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import logging
from datetime import datetime, timedelta, timezone

from lib.logger_setup import configure_logger
from lib.http_utils import parse_json_body, respond
from lib.user_context import get_user_id_from_request
from lib.firestore_client import (
    get_firestore_client,
    get_user_event_doc,
    get_event_checklist_collection,
    get_event_checklist_item,
)
from lib.firestore_utils import serialize_firestore_dict
from lib.validators import validate_exact_fields
from lib.exceptions import ValidationError

# ログ設定
configure_logger()
logger = logging.getLogger(__name__)
db = get_firestore_client("hisho-events")

# JST定義
JST = timezone(timedelta(hours=9))


def ensure_jst_datetime(dt_or_str):
    """
    Firestoreから取得したdatetimeまたはstringを、JSTのaware datetimeに正規化する
    """
    if isinstance(dt_or_str, datetime):
        return dt_or_str
    elif isinstance(dt_or_str, str):
        dt = datetime.fromisoformat(dt_or_str)
        return dt if dt.tzinfo else dt.replace(tzinfo=JST)
    else:
        raise ValueError("Unsupported datetime format")


class RequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        try:
            # Firebase Auth ヘッダーから user_id 抽出
            user_id = get_user_id_from_request(self.headers)

            # リクエストボディ読み込み
            data = parse_json_body(self)
            validate_exact_fields(data, ["event_id", "checklist_id", "checked"])
            event_id = data["event_id"]
            checklist_id = data["checklist_id"]
            checked = data["checked"]

            # 該当チェックリスト項目の更新
            checklist_ref = get_event_checklist_item(
                db, user_id, event_id, checklist_id
            )
            checklist_ref.update({"checked": checked})
            logger.info(
                f"✅ Checked updated for checklist_id={checklist_id}: {checked}"
            )

            # イベント取得 & start_date をJST datetimeで取得
            event_ref = get_user_event_doc(db, user_id, event_id)
            event_doc = event_ref.get()
            if not event_doc.exists:
                respond(self, 404, {"error": "event not found"})
                return
            event_data = event_doc.to_dict()
            start_date = ensure_jst_datetime(event_data.get("start_time"))

            # 未チェック項目を取得して next_check_due を再計算
            checklist_collection = get_event_checklist_collection(db, user_id, event_id)
            unprepared_items = checklist_collection.where(
                "checked", "==", False
            ).stream()

            min_due = None
            for doc in unprepared_items:
                item = doc.to_dict()
                prepare_days = item.get("prepare_before", 0)
                due_date = start_date - timedelta(days=prepare_days)
                if min_due is None or due_date < min_due:
                    min_due = due_date

            # next_check_due を更新（未チェックがなければ null）
            event_ref.update({"next_check_due": min_due})
            logger.info(f"🕐 Updated next_check_due: {min_due}")

            # レスポンスを JST ISO文字列で返却
            response_data = (
                {"next_check_due": min_due} if min_due else {"next_check_due": None}
            )
            respond(
                self,
                status=200,
                body={"status": "success", **serialize_firestore_dict(response_data)},
            )
        except ValidationError as ve:
            logger.warning(f"⚠️ Validation failed: {ve}")
            respond(self, status=400, body={"error": str(ve)})
        except Exception as e:
            logger.exception("❌ Request processing failed")
            respond(self, status=500, body={"error": str(e)})


def run():
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("", port), RequestHandler)
    logger.info(f"サーバー起動 ポート: {port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
