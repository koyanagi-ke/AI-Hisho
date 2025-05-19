import os
import json
import google.cloud.firestore
from dotenv import load_dotenv

# .envファイルを読み込む
load_dotenv()

db = google.cloud.firestore.Client(database='hisho-events')

def get_all_players():
    results = db.collection('users').document('se0e3x3pee4NuXYUlIbf').collection('events').stream()
    data_list = [doc.to_dict() for doc in results]

    for doc in results:
        print(f'{doc.id}')

    print(data_list)

if __name__ == '__main__':
    get_all_players()