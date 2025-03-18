import cv2
import numpy as np
import matplotlib.pyplot as plt

def detect_objects_with_contours(image_path, min_area=5000, max_area=500000, 
                                canny_low=50, canny_high=150, 
                                aspect_ratio_min=0.3, aspect_ratio_max=3.0):
    # Resmi yükle
    img = cv2.imread(image_path)
    
    if img is None:
        print(f"HATA: Resim yüklenemedi: {image_path}")
        return
    
    # Resmi gri tonlamaya dönüştür
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Gürültüyü azaltmak için Gaussian bulanıklaştırma uygula
    blurred = cv2.GaussianBlur(gray, (7, 7), 0)
    
    # Kenar tespiti için Canny algoritması kullan
    edges = cv2.Canny(blurred, canny_low, canny_high)
    
    # Kenarları genişlet
    kernel = np.ones((5, 5), np.uint8)
    dilated = cv2.dilate(edges, kernel, iterations=2)
    
    # Konturları bul
    contours, _ = cv2.findContours(dilated.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    print(f"Toplam {len(contours)} kontur bulundu.")
    
    # Filtrelenmiş konturları sakla
    filtered_contours = []
    
    # Konturları filtrele (alan, en-boy oranı vb. kriterlere göre)
    for contour in contours:
        area = cv2.contourArea(contour)
        
        # Alan filtreleme
        if not (min_area < area < max_area):
            continue
        
        # En-boy oranı filtreleme
        x, y, w, h = cv2.boundingRect(contour)
        aspect_ratio = float(w) / h if h > 0 else 0
        
        if not (aspect_ratio_min < aspect_ratio < aspect_ratio_max):
            continue
        
        # Şekil karmaşıklığı filtreleme
        perimeter = cv2.arcLength(contour, True)
        complexity = perimeter / (4 * np.sqrt(area)) if area > 0 else 0
        
        if complexity > 2.5:  # Çok karmaşık şekilleri filtrele
            continue
        
        filtered_contours.append(contour)
    
    print(f"Filtreleme sonrası {len(filtered_contours)} kontur kaldı.")
    
    # Sonuç resmini oluştur
    result_img = img.copy()
    
    # Her kontur için bounding box çiz
    for i, contour in enumerate(filtered_contours):
        x, y, w, h = cv2.boundingRect(contour)
        cv2.rectangle(result_img, (x, y), (x + w, y + h), (0, 255, 0), 2)
        cv2.putText(result_img, f"Nesne {i+1}", (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
    
    # Toplam nesne sayısını resmin üstüne yaz
    cv2.putText(result_img, f"Toplam Nesne Sayisi: {len(filtered_contours)}", (10, 30), 
                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
    
    # Sonuçları göster
    plt.figure(figsize=(15, 10))
    
    plt.subplot(2, 2, 1)
    plt.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
    plt.title("Orijinal Resim")
    plt.axis('off')
    
    plt.subplot(2, 2, 2)
    plt.imshow(edges, cmap='gray')
    plt.title("Kenar Tespiti")
    plt.axis('off')
    
    plt.subplot(2, 2, 3)
    plt.imshow(dilated, cmap='gray')
    plt.title("Genişletilmiş Kenarlar")
    plt.axis('off')
    
    plt.subplot(2, 2, 4)
    plt.imshow(cv2.cvtColor(result_img, cv2.COLOR_BGR2RGB))
    plt.title(f"Tespit Edilen Nesneler: {len(filtered_contours)}")
    plt.axis('off')
    
    plt.tight_layout()
    plt.show()
    
    # Sonuç resmini kaydet
    output_path = image_path.replace('.jpeg', '_improved_contour.jpeg').replace('.png', '_improved_contour.png')
    cv2.imwrite(output_path, result_img)
    print(f"Sonuç resmi kaydedildi: {output_path}")
    
    return len(filtered_contours)

if __name__ == "__main__":
    # Test resmi yolu
    image_path = "test.jpeg"
    
    # Nesne tespiti yap - parametreleri resminize göre ayarlayabilirsiniz
    object_count = detect_objects_with_contours(
        image_path, 
        min_area=10000,       # Minimum nesne alanı
        max_area=300000,      # Maksimum nesne alanı
        canny_low=30,         # Canny alt eşik
        canny_high=100,       # Canny üst eşik
        aspect_ratio_min=0.5, # Minimum en-boy oranı
        aspect_ratio_max=2.0  # Maksimum en-boy oranı
    ) 