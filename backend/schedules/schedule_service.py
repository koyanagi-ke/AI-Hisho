from datetime import datetime

def fetch_schedules(user_id, start_time, end_time):
    # DBからの取得部分を実装してください
    all_records = [
        {"user_id": "user123", "start_time": "2025-05-05T09:00:00", "title": "会議", "analysis": "重要"},
        {"user_id": "user123", "start_time": "2025-05-15T13:00:00", "title": "面談", "analysis": "普通"},
        {"user_id": "user999", "start_time": "2025-05-10T10:00:00", "title": "他ユーザー予定", "analysis": "低"},
    ]
    s = datetime.fromisoformat(start_time)
    e = datetime.fromisoformat(end_time)
    result = [
        r for r in all_records
        if r["user_id"] == user_id and s <= datetime.fromisoformat(r["start_time"]) <= e
    ]
    return result

def format_schedules(records):
    return [
        {
            "start_time": r["start_time"],
            "title": r["title"],
            "analysis": r["analysis"]
        }
        for r in records
    ]