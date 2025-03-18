# Ürün Tespit Uygulaması

Bu uygulama, bir resimde bulunan ürünleri tespit etmek için YOLOv5 nesne tespit modelini kullanır.

## Kurulum

1. Gerekli paketleri yükleyin:
```
pip install -r requirements.txt
```

2. İlk çalıştırmada YOLOv5 modeli otomatik olarak indirilecektir.

## Kullanım

1. Tespit etmek istediğiniz ürünlerin bulunduğu resmi projenin ana dizinine koyun (örneğin: `test.jpg`).

2. Kodu çalıştırın:
```
python object_detection.py
```

3. Varsayılan olarak kod `test.jpg` dosyasını arayacaktır. Farklı bir dosya kullanmak için `object_detection.py` dosyasını açıp `image_path` değişkenini değiştirin.

## Çıktı

- Program, tespit edilen ürünlerin etrafına yeşil bounding box'lar çizer.
- Her bounding box'ın üstünde tespit güven değeri gösterilir.
- Resmin üst kısmında toplam tespit edilen ürün sayısı gösterilir.
- Tespit sonuçları konsola yazdırılır.
- İşlenmiş resim, orijinal dosya adının sonuna "_detected" eklenerek kaydedilir.

## Not

Bu uygulama, YOLOv5 modelinin tanıyabildiği nesneler arasından ürün olabilecek olanları (şişe, bardak, kitap, vb.) tespit eder. Eğer tüm nesneleri tespit etmek isterseniz, kodda bulunan `product_classes` listesini kaldırabilirsiniz. 