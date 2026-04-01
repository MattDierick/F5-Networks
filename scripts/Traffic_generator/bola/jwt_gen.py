import base64
import json
import hmac
import hashlib
import random
import string

# Configuration
SECRET = "YOUR_SECRET"
ALGORITHM = "HS256"
NUM_TOKENS = 100  # number of lines / tokens to generate

# Base header and payload
HEADER = {"typ": "JWT", "alg": ALGORITHM, "kid": "0001"}
BASE_PAYLOAD = {
    "iat": 1739882355,
    "exp": 2362060800,
}

# Helper: base64url encode (no padding)
def base64url_encode(input_bytes: bytes) -> str:
    return base64.urlsafe_b64encode(input_bytes).decode("utf-8").replace("=", "")

# Generate a single JWT without any external library
def make_jwt(user_id: str, role: str) -> str:
    header_b64 = base64url_encode(
        json.dumps(HEADER, separators=(",", ":")).encode("utf-8")
    )
    payload = {**BASE_PAYLOAD, "user_id": user_id, "role": role}
    payload_b64 = base64url_encode(
        json.dumps(payload, separators=(",", ":")).encode("utf-8")
    )

    signing_input = f"{header_b64}.{payload_b64}"
    signature = hmac.new(
        SECRET.encode("utf-8"),
        signing_input.encode("utf-8"),
        hashlib.sha256,
    ).digest()
    signature_b64 = base64url_encode(signature)

    return f"{signing_input}.{signature_b64}"

# Generate tokens and write to file
with open("tokens.txt", "w") as f:
    for _ in range(NUM_TOKENS):
        # Random 8‑char user_id (letters + digits)
        user_id = "".join(
            random.choices(string.ascii_letters + string.digits, k=8)
        )
        # Random role: admin or user
        role = random.choice(["admin", "user"])
        token = make_jwt(user_id, role)
        f.write(token + "\n")

print(f"Wrote {NUM_TOKENS} JWT tokens to tokens.txt")