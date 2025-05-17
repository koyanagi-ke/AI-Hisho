import base64
import json
import functions_framework
from google.auth import default
from google.auth.transport.requests import Request
import requests
from firebase_functions.firestore_fn import (
    on_document_created,
    Event,
    DocumentSnapshot,
)


@on_document_created(document="users/{userId}")
@functions_framework.cloud_event
def firestore_trigger(cloud_event):
    data = json.loads(cloud_event.data)

    doc_path = data["value"]["name"]
    event_id = doc_path.split("/")[-1]
    user_id = doc_path.split("/")[-3]

    print(f"[INFO] Triggered by userId: {user_id}, eventId: {event_id}")

    # 認証トークン取得（サービスアカウント）
    credentials, project = default(
        scopes=["https://www.googleapis.com/auth/cloud-platform"]
    )
    credentials.refresh(Request())

    # Cloud Workflows 実行エンドポイント
    workflow_url = workflow_url = (
        "https://workflowexecutions.googleapis.com/v1/projects/ai-hisho-458317/locations/asia-northeast1/workflows/firestore_trigger_workflow/executions"
    )

    headers = {
        "Authorization": f"Bearer {credentials.token}",
        "Content-Type": "application/json",
    }

    payload = {"argument": json.dumps({"userId": user_id, "eventId": event_id})}

    response = requests.post(workflow_url, headers=headers, json=payload)
    print(f"Workflow triggered: {response.status_code} {response.text}")
