from google.cloud import secretmanager


def get_openweathermap_api_key():
    client = secretmanager.SecretManagerServiceClient()
    secret_path = "projects/131464926474/secrets/OPENWEATHERMAP_API_KEY/versions/latest"
    response = client.access_secret_version(request={"name": secret_path})
    return response.payload.data.decode("UTF-8")
