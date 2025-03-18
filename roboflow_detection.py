import cv2
import numpy as np
from roboflow import Roboflow
import matplotlib.pyplot as plt

def detect_objects_with_roboflow(image_path, api_key, model_workspace, model_name, model_version):
    """
    Roboflow'da eğitilmiş bir model kullanarak nesneleri tespit eder.
    
    Args:
        image_path (str): Resim dosyasının yolu
        api_key (str): Roboflow API anahtarı
        model_workspace (str): Roboflow çalışma alanı adı
        model_name (str): Model adı
        model_version (int): Model versiyonu
    """
    # Roboflow API'ye bağlan
    rf = Roboflow(api_key=api_key)
    project = rf.workspace(model_workspace).project(model_name)
    model = project.version(model_version).model
    
    # Resmi yükle
    img = cv2.imread(image_path)
    if img is None:
        print(f"HATA: Resim yüklenemedi: {image_path}")
        return
    
    # Resmi RGB'ye dönüştür (görselleştirme için)
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Nesne tespiti yap
    predictions = model.predict(image_path, confidence=40, overlap=30).json()
    
    # Sonuç resmini oluştur
    result_img = img_rgb.copy()
    
    # Tespit edilen nesneleri say
    object_count = len(predictions['predictions'])
    
    print(f"Tespit edilen toplam nesne sayısı: {object_count}")
    
    # Her tespit için bounding box çiz
    for i, prediction in enumerate(predictions['predictions']):
        # Bounding box koordinatlarını al
        x1 = prediction['x'] - prediction['width'] / 2
        y1 = prediction['y'] - prediction['height'] / 2
        x2 = prediction['x'] + prediction['width'] / 2
        y2 = prediction['y'] + prediction['height'] / 2
        
        # Koordinatları integer'a dönüştür
        x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)
        
        # Bounding box çiz
        cv2.rectangle(result_img, (x1, y1), (x2, y2), (0, 255, 0), 2)
        
        # Etiket ve güven değerini göster
        label = f"{prediction['class']}: {prediction['confidence']:.2f}"
        cv2.putText(result_img, label, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
    
    # Toplam nesne sayısını resmin üstüne yaz
    cv2.putText(result_img, f"Toplam Nesne Sayisi: {object_count}", (10, 30), 
                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
    
    # Sonuçları göster
    plt.figure(figsize=(12, 8))
    plt.imshow(result_img)
    plt.title(f"Tespit Edilen Nesneler: {object_count}")
    plt.axis('off')
    plt.show()
    
    # Sonuç resmini kaydet
    output_path = image_path.replace('.jpeg', '_roboflow_detected.jpeg').replace('.png', '_roboflow_detected.png')
    cv2.imwrite(output_path, cv2.cvtColor(result_img, cv2.COLOR_RGB2BGR))
    print(f"Sonuç resmi kaydedildi: {output_path}")
    
    return object_count

if __name__ == "__main__":
    # Test resmi yolu
    image_path = "test.jpeg"
    
    # Roboflow API bilgileri - BU BİLGİLERİ KENDİ ROBOFLOW HESABINIZLA DEĞİŞTİRİN
    api_key = "YOUR_API_KEY"  # Roboflow hesabınızdan alacağınız API anahtarı
    model_workspace = "your-workspace"  # Roboflow çalışma alanı adınız
    model_name = "your-project"  # Projenizin adı
    model_version = 1  # Model versiyonu
    
    # Nesne tespiti yap
    object_count = detect_objects_with_roboflow(
        image_path, 
        api_key, 
        model_workspace, 
        model_name, 
        model_version
    ) 