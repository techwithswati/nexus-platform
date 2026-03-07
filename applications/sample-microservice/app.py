from flask import Flask, jsonify
import os
import random
import time

app = Flask(__name__)

# Simulated metrics
request_count = 0
start_time = time.time()

@app.route('/')
def home():
    global request_count
    request_count += 1
    return jsonify({
        "service": "Nexus Platform Sample Microservice",
        "version": "1.0.0",
        "status": "healthy",
        "environment": os.getenv("ENVIRONMENT", "development"),
        "requests_handled": request_count
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

@app.route('/metrics')
def metrics():
    uptime = time.time() - start_time
    return jsonify({
        "requests_total": request_count,
        "uptime_seconds": round(uptime, 2),
        "error_rate": 0.02,
        "response_time_ms": random.uniform(100, 200)
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
