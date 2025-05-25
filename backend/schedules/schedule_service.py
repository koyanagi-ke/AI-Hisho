from datetime import datetime

def fetch_schedules(user_id, start_time, end_time):
    if start_time and end_time:
        s = datetime.fromisoformat(start_time)
        e = datetime.fromisoformat(end_time)
        result = [
            r for r in all_records
            if r["user_id"] == user_id and s <= datetime.fromisoformat(r["start_time"]) <= e
        ]
    else:
        result = [r for r in all_records if r["user_id"] == user_id]
    return result

def format_schedules(records):
    return [
        {
            "title": r["title"],
            "start_time": r["start_time"],
            "end_time": r["end_time"]
            "location": r["location"]
        }
        for r in records
    ]