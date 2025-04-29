# ベースイメージ
FROM python:3.12-slim

# 作業ディレクトリ作成
WORKDIR /app

# 必要パッケージコピーしてインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ソースコードをコピー
COPY . .

# アプリケーション実行コマンド
CMD ["python", "main.py"]
