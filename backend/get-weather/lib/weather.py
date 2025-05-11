import requests
from .geocode_address import geocode_address_nominatim


def _get_forecast(lat: float, lon: float, api_key: str):
    url = "https://api.openweathermap.org/data/2.5/forecast"
    params = {"lat": lat, "lon": lon, "appid": api_key, "units": "metric", "lang": "ja"}
    response = requests.get(url, params=params)
    response.raise_for_status()
    return response.json()


def fetch_weather_for_document(doc, api_key: str):
    address = doc.get("address")
    if not address:
        return {}
    lat, lon = geocode_address_nominatim(address)
    forecast = _get_forecast(lat, lon, api_key)
    return forecast

