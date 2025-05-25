from lib.gemini_client import generate_checklist_items
from datetime import timedelta, timezone, datetime


def generate_item_per_record(event_ref):
    event_doc = event_ref.get()
    event = event_doc.to_dict()
    datetime = event.get("start_time", "")
    location = event.get("location", "")
    description = event.get("title", "")

    checklist_ref = event_ref.collection("checklists")
    weather_info = event.get("weather_info")

    docs = list(checklist_ref.stream())

    if not docs:
        result = generate_checklist_items(
            datetime, location, description, weather_info=weather_info
        )
    else:
        items = [doc.to_dict().get("item") for doc in docs if "item" in doc.to_dict()]
        result = generate_checklist_items(
            datetime, location, description, items, weather_info
        )

    for category in ["required", "optional"]:
        for item in result.get(category, []):
            checklist_ref.document().set(
                {
                    "item": item.get("item"),
                    "prepare_before": item.get("prepare_before", 0),
                    "required": category == "required",
                    "checked": False,
                }
            )

    return result


def update_next_check_due(event_ref, result):

    event = event_ref.get().to_dict()
    event_start = event.get("start_time")
    soonest_due = None

    for category in ["required", "optional"]:
        for item in result.get(category, []):
            due = event_start - timedelta(days=item.get("prepare_before", 0))
            if soonest_due is None or due < soonest_due:
                soonest_due = due

    # events に反映
    event_ref.update({"next_check_due": soonest_due})
