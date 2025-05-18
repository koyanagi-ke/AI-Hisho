import os
import firebase_admin
from firebase_admin import credentials, auth

cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
if not firebase_admin._apps:
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

def verify_firebase_token(headers):
    auth_header = headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise ValueError("Authorization header missing or malformed")

    id_token = auth_header.split(" ")[1]
    decoded_token = auth.verify_id_token(id_token)
    return decoded_token["uid"]
