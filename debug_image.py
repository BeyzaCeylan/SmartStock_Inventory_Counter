import cv2
import matplotlib.pyplot as plt
import torch

def check_image(image_path):
    # Resmi OpenCV ile yükle
    img = cv2.imread(image_path)
    
    if img is None:
        print(f"HATA: Resim yüklenemedi: {image_path}")
        return False
    
    # Resmin boyutlarını ve tipini yazdır
    print(f"Resim boyutları: {img.shape}")
    print(f"Resim tipi: {img.dtype}")
    
    # Resmi BGR'dan RGB'ye dönüştür (matplotlib için)
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Resmi göster
    plt.figure(figsize=(10, 8))
    plt.imshow(img_rgb)
    plt.title("Yüklenen Resim")
    plt.axis('off')
    plt.show()
    
    # YOLOv5 ile çok düşük güven eşiği kullanarak tespit dene
    model = torch.hub.load('ultralytics/yolov5', 'yolov5s', pretrained=True)
    
    # Güven eşiğini çok düşük ayarla (0.05)
    model.conf = 0.05
    
    # Resmi modele gönder
    results = model(img_rgb)
    
    # Sonuçları yazdır
    print("\nTespit edilen tüm nesneler (düşük güven eşiği ile):")
    print(results.pandas().xyxy[0])
    
    # Sonuçları görselleştir
    results_img = results.render()[0]  # Render sonuçları
    
    plt.figure(figsize=(10, 8))
    plt.imshow(results_img)
    plt.title("Tespit Sonuçları (Güven Eşiği: 0.05)")
    plt.axis('off')
    plt.show()
    
    return True

if __name__ == "__main__":
    # Test resmi yolu
    image_path = "test.jpeg"
    
    # Resmi kontrol et
    check_image(image_path) 