import cv2
import numpy as np
import matplotlib.pyplot as plt
from roboflow import Roboflow
import os

def detect_objects_with_roboflow(image_path, api_key, project_id, version_number, confidence=40, overlap=30, show_plot=True):
    """
    Roboflow API kullanarak nesneleri tespit eder.
    
    Args:
        image_path (str): Resim dosyasının yolu
        api_key (str): Roboflow API anahtarı
        project_id (str): Proje ID'si (örn: "my-first-project-9flm1")
        version_number (int): Model versiyonu (örn: 1)
        confidence (int): Güven eşiği (0-100)
        overlap (int): Örtüşme eşiği (0-100)
        show_plot (bool): Sonuçları matplotlib ile gösterip göstermeme
    """
    # Dosyanın varlığını kontrol et
    if not os.path.exists(image_path):
        print(f"HATA: Dosya bulunamadı: {image_path}")
        return None
    
    # Roboflow API'ye bağlan
    rf = Roboflow(api_key=api_key)
    
    # Workspace belirtmeden doğrudan projeye erişim
    project = rf.workspace().project(project_id)
    model = project.version(version_number).model
    
    # Resmi yükle
    img = cv2.imread(image_path)
    if img is None:
        print(f"HATA: Resim yüklenemedi: {image_path}")
        return None
    
    # Resmi RGB'ye dönüştür (görselleştirme için)
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    try:
        # Nesne tespiti yap
        predictions = model.predict(image_path, confidence=confidence, overlap=overlap).json()
        
        # Sonuç resmini oluştur
        result_img = img_rgb.copy()
        
        # Tespit edilen nesneleri say
        object_count = len(predictions['predictions'])
        
        print(f"Resim: {image_path} - Tespit edilen toplam nesne sayısı: {object_count}")
        
        # Her tespit için bounding box çiz
        for i, prediction in enumerate(predictions['predictions']):
            # Bounding box koordinatlarını al
            x1 = prediction['x'] - prediction['width'] / 2
            y1 = prediction['y'] - prediction['height'] / 2
            x2 = prediction['x'] + prediction['width'] / 2
            y2 = prediction['y'] + prediction['height'] / 2
            
            # Koordinatları integer'a dönüştür
            x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)
            
            # Bounding box çiz - kalınlığı 4 yaptık
            cv2.rectangle(result_img, (x1, y1), (x2, y2), (0, 255, 0), 4)
            
            # Etiket ve güven değerini göster
            class_name = prediction.get('class', 'unknown')
            confidence = prediction.get('confidence', 0)
            label = f"{class_name}: {confidence:.2f}"
            
            # Etiket arka planı için dikdörtgen çiz
            label_size, _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 1.0, 2)
            cv2.rectangle(result_img, (x1, y1 - label_size[1] - 10), (x1 + label_size[0], y1), (0, 255, 0), -1)
            
            # Etiket metnini yaz
            cv2.putText(result_img, label, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 0, 0), 2)
        
        # Toplam nesne sayısını resmin üstüne yaz
        cv2.putText(result_img, f"Toplam Nesne Sayisi: {object_count}", (10, 50), 
                    cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0, 0, 255), 3)
        
        # Sonuçları göster (isteğe bağlı)
        if show_plot:
            plt.figure(figsize=(12, 8))
            plt.imshow(result_img)
            plt.title(f"Tespit Edilen Nesneler: {object_count} - {image_path}")
            plt.axis('off')
            plt.show()
        
        # Sonuç resmini kaydet
        output_path = image_path.replace('.jpeg', '_roboflow_detected.jpeg').replace('.png', '_roboflow_detected.png').replace('.jpg', '_roboflow_detected.jpg').replace('.webp', '_roboflow_detected.webp')
        cv2.imwrite(output_path, cv2.cvtColor(result_img, cv2.COLOR_RGB2BGR))
        print(f"Sonuç resmi kaydedildi: {output_path}")
        
        return object_count
    
    except Exception as e:
        print(f"HATA: Nesne tespiti sırasında bir hata oluştu: {str(e)}")
        return None

if __name__ == "__main__":
    # Roboflow API bilgileri
    api_key = "pkxgxcybbmjDhVQZ9UCZ"  # API anahtarınız
    project_id = "my-first-project-9flm1"  # Projenizin ID'si
    version_number = 1  # Model versiyonu
    
    # Test edilecek tüm resim dosyaları
    image_paths = [
        "test.jpeg", 
        "testttt.jpeg", 
        "test2.jpg", 
        "test3.webp", 
        "test5.jpeg", 
        "test6.jpeg", 
        "test7.jpg",
        "coca-cola-kutu-200-ml-24lu-gazli-icecekler-coca-cola-7714-81-B.png",
        "test8.jpeg"
    ]
    
    # Her resim için ayrı ayrı nesne tespiti yap
    for i, image_path in enumerate(image_paths):
        print(f"\n{'-'*50}")
        print(f"Resim dosyası ({i+1}/{len(image_paths)}): {image_path} işleniyor...")
        print(f"{'-'*50}")
        
        # Nesne tespiti yap
        object_count = detect_objects_with_roboflow(
            image_path, 
            api_key, 
            project_id,
            version_number,
            confidence=40,  # Güven eşiği
            overlap=30,     # Örtüşme eşiği
            show_plot=True  # Sonuçları göster
        )
        
        if object_count is not None:
            print(f"{'-'*50}")
            print(f"Resim dosyası: {image_path} işlendi. Tespit edilen nesne sayısı: {object_count}")
        else:
            print(f"{'-'*50}")
            print(f"Resim dosyası: {image_path} işlenemedi.")
        
        print(f"{'-'*50}\n")
    
    print("Tüm resimler işlendi. Sonuçlar kaydedildi.") 