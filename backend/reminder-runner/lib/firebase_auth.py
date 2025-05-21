import firebase_admin
from firebase_admin import credentials, initialize_app

from lib.secret_manager_client import setup_firebase_credentials_env


def firebase_configure():
    # 認証情報を読み込み & 初期化
    cred_path = setup_firebase_credentials_env()
    if not firebase_admin._apps:
        cred = credentials.Certificate(cred_path)
        initialize_app(cred)
