import requests
import json

# エンドポイント
url = 'https://ai-hisho-hackathon-gw-1oe6tmh6.an.gateway.dev/api/schedules'
headers = {
    "Content-Type": "application/json",
    'Authorization': f'Bearer {api_token}'
}

data = {
    "start_time": "2025-05-01T00:00:00",
    "end_time": "2025-05-31T23:59:59"
}

# リクエスト
res = requests.post(url, headers=headers, json=data)
values = json.loads(res.text)

print(values)