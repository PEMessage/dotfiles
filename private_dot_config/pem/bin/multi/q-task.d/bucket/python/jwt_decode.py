import sys, json, base64

def b64url_decode(s):
    return base64.urlsafe_b64decode(s + '=' * (-len(s) % 4))

token = sys.stdin.read().strip()
parts = token.split('.')

result = {
    'header': json.loads(b64url_decode(parts[0])),
    'payload': json.loads(b64url_decode(parts[1]))
}

print(json.dumps(result, indent=2))
