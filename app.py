from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
from roboflow import Roboflow
import os

app = Flask(__name__)
CORS(app)

# Roboflow API bilgileri
ROBOFLOW_API_KEY = "pkxgxcybbmjDhVQZ9UCZ"
PROJECT_ID = "my-first-project-9flm1"
VERSION_NUMBER = 2

print("Model yükleniyor...")
rf = Roboflow(api_key=ROBOFLOW_API_KEY)
project = rf.workspace().project(PROJECT_ID)
model = project.version(VERSION_NUMBER).model

@app.route('/detect', methods=['POST'])
def detect():
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file uploaded'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        # Gelen dosyayı kaydet
        temp_path = 'temp_image.jpg'
        file.save(temp_path)
        
        # Nesne tespiti yap
        predictions = model.predict(temp_path, confidence=25, overlap=15).json()
        
        # Nesne sayılarını hesapla
        object_counts = {}
        for prediction in predictions['predictions']:
            class_name = prediction.get('class', 'unknown')
            class_name = class_name.replace('sut', 'süt').replace('yogurt', 'yoğurt')
            confidence = prediction.get('confidence', 0)
            
            if confidence >= 0.25:
                if class_name in object_counts:
                    object_counts[class_name] += 1
                else:
                    object_counts[class_name] = 1
        
        # Geçici dosyayı sil
        if os.path.exists(temp_path):
            os.remove(temp_path)
        
        return jsonify({
            'success': True,
            'object_counts': object_counts
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)