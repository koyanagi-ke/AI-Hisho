import json


def parse_json_body(request):
    content_length = int(request.headers.get("Content-Length", 0))
    body = request.rfile.read(content_length).decode("utf-8")
    return json.loads(body) if body else {}


def respond(handler, status=200, body=None):
    handler.send_response(status)
    handler.send_header("Content-type", "application/json")
    handler.end_headers()
    if body is not None:
        handler.wfile.write(json.dumps(body).encode("utf-8"))
