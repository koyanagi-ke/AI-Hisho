from http.server import BaseHTTPRequestHandler, HTTPServer
import logging
import os

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

        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(b"OK")


def run():
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("", port), RequestHandler)
    logger.info(f"サーバー起動 ポート: {port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
