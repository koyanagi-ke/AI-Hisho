import json

def parse_json_body(request):
    content_length = int(request.headers.get('Content-Length', 0))
    body_bytes = request.rfile.read(content_length)
    body_str = body_bytes.decode('utf-8')
    try:
        return json.loads(body_str)
    except Exception:
        raise Exception("Malformed JSON body")