import google.cloud.firestore

def get_schedules_by_user_and_period(user_id, start_time, end_time):
    db = google.cloud.firestore.Client(database='hisho-events')
    
    results = {
        db.collection('users').document('se0e3x3pee4NuXYUlIbf').collection('events')
        .where("user_id", "==", user_id)
        .where("start_time", ">=", start_time)
        .where("end_time", "<=", end_time)
        .order_by("start_time").stream()
    }
    return result