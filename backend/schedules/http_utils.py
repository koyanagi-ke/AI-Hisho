import json

def parse_json_body(request):
    content_length = int(request.headers.get("Content-Length", 0))
    body = request.rfile.read(content_length).decode("utf-8")
    return json.loads(body) if body else {}