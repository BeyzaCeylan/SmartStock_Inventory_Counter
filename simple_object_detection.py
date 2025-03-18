import torch
import cv2
import numpy as np

def detect_objects(image_path, confidence_threshold=0.25):
    # YOLOv5 modelini yükle
    model = torch.hub.load('ultralytics/yolov5', 'yolov5s', pretrained=True)
    
    # Güven eşiğini ayarla
    model.conf = confidence_threshold
    
    # Resmi yükle ve modele gönder
    results = model(image_path)
    
    # Sonuçları al
    detections = results.pandas().xyxy[0]
    
    # Resmi OpenCV formatında yükle
    img = cv2.imread(image_path)
    
    # Tespit edilen her nesne için bounding box çiz
    object_count = len(detections)
    
    for idx, detection in detections.iterrows():
        x1, y1, x2, y2 = int(detection['xmin']), int(detection['ymin']), int(detection['xmax']), int(detection['ymax'])
        confidence = detection['confidence']
        
        # Bounding box çiz
        cv2.rectangle(img, (x1, y1), (x2, y2), (0, 255, 0), 2)
        
        # Güven değerini göster
        label = f"{confidence:.2f}"
        cv2.putText(img, label, (x1, y1-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
    
    # Toplam nesne sayısını resmin üstüne yaz
    cv2.putText(img, f"Toplam Nesne Sayisi: {object_count}", (10, 30), 
                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
    
    print(f"Tespit edilen toplam nesne sayısı: {object_count}")
    
    # Sonuç resmini göster
    cv2.imshow("Object Detection", img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    
    # Sonuç resmini kaydet
    output_path = image_path.replace('.jpeg', '_detected.jpeg').replace('.png', '_detected.png')
    cv2.imwrite(output_path, img)
    print(f"Sonuç resmi kaydedildi: {output_path}")
    
    return object_count

if __name__ == "__main__":
    # Test resmi yolu
    image_path = "test.jpeg"  # Bu dosya yolunu kendi resminize göre değiştirin
    
    # Nesne tespiti yap
    object_count = detect_objects(image_path) 