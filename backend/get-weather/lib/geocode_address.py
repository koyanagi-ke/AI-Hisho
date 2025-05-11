from geopy.geocoders import Nominatim


def geocode_address_nominatim(address: str):
    geolocator = Nominatim(user_agent="your-app-name")  # 任意の名前でOK
    location = geolocator.geocode(address)
    if not location:
        raise ValueError(f"住所のジオコーディングに失敗しました: {address}")
    return location.latitude, location.longitude
