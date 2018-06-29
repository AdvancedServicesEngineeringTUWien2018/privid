import base64
import face_recognition
import numpy as np
import PIL.Image
import re
import uuid

from flask import Flask, jsonify, request, abort
from flask_cors import CORS
from io import BytesIO

# In-memory storage for face embeddings, indexed by ID
face_embeddings = {}

app = Flask(__name__)
CORS(app)  # Allow all domains, all routes


def create_uuid():
    return str(uuid.uuid4())


def load_base64_image(str):
    image_data = base64.b64decode(re.sub("^data:image/.+;base64,", "", str))
    im = PIL.Image.open(BytesIO(image_data))
    return np.array(im)


# Generates embedding for image with a face
# Always return for the first face we find
def extract_embedding(image):
    img = load_base64_image(image)
    encodings = face_recognition.api.face_encodings(img)

    if not encodings:
        raise Exception("No face present in image")

    return encodings[0]


@app.route("/", methods=["POST"])
def web_recognize():
    data = request.get_json()
    if not data:
        return abort(400)

    # Get embedding from image
    parsed_data = data
    embedding = None
    try:
        embedding = extract_embedding(parsed_data["img"])
    except Exception:
        return abort(400)

    ids_embeddings = list(face_embeddings.items())
    known_embeddings = [x[1] for x in ids_embeddings]

    match_results = face_recognition.compare_faces(known_embeddings, embedding)
    for i, match in enumerate(match_results):
        if match:
            # Return the first match
            dist = face_recognition.api.face_distance(
                [ids_embeddings[i][1]], embedding
            )[0]
            return jsonify({"id": ids_embeddings[i][0], "distance": dist})

    # Not in storage, add it
    new_id = create_uuid()
    while new_id in face_embeddings:
        new_id = create_uuid()

    face_embeddings[new_id] = embedding
    return jsonify({"id": new_id})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
