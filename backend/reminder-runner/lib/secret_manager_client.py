from google.cloud import secretmanager
import os
import tempfile


def get_openweathermap_api_key():
    client = secretmanager.SecretManagerServiceClient()
    secret_path = "projects/131464926474/secrets/OPENWEATHERMAP_API_KEY/versions/latest"
    response = client.access_secret_version(request={"name": secret_path})
    return response.payload.data.decode("UTF-8")


def get_gemini_api_key():
    client = secretmanager.SecretManagerServiceClient()
    secret_path = "projects/131464926474/secrets/GEMINI_API_KEY/versions/latest"
    response = client.access_secret_version(request={"name": secret_path})
    os.environ["GOOGLE_API_KEY"] = response.payload.data.decode("UTF-8")


def setup_firebase_credentials_env():
    # Secret取得
    os.environ.pop("GOOGLE_APPLICATION_CREDENTIALS", None)
    client = secretmanager.SecretManagerServiceClient()
    secret_path = "projects/131464926474/secrets/FIREBASE_CREDENTIALS/versions/latest"
    response = client.access_secret_version(request={"name": secret_path})
    json_str = response.payload.data.decode("UTF-8")

    # 一時ファイルへ保存
    with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as f:
        f.write(json_str)
        temp_path = f.name

    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = temp_path
    return temp_path
