from flask import Flask, request, jsonify, render_template
import base64
import hashlib

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')

@app.route('/v1/api/encode', methods=['POST'])
def encode():
    data = request.json.get('text', '')
    encoded_data = base64.b64encode(data.encode()).decode()
    return jsonify({'encoded': encoded_data})

@app.route('/v1/api/decode', methods=['POST'])
def decode():
    data = request.json.get('encoded', '')
    decoded_data = base64.b64decode(data.encode()).decode()
    return jsonify({'decoded': decoded_data})

@app.route('/v1/api/hash', methods=['POST'])
def hash_text():
    data = request.json.get('text', '')
    print(data)
    hashed_data = hashlib.sha256(data.encode()).hexdigest()
    return jsonify({'hashed': hashed_data})

@app.route('/v1/api/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port='5000', debug=True)