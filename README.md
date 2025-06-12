# SmartStock 📦📷

SmartStock, akıllı telefon üzerinden görsel tabanlı ürün tanıma ve stok sayımı gerçekleştiren yapay zekâ destekli bir mobil stok takip uygulamasıdır. Proje, nesne tanıma için YOLOv8 modeli ve Flutter tabanlı bir kullanıcı arayüzü ile geliştirilmiştir. Firebase entegrasyonu sayesinde veriler güvenli bir şekilde bulutta saklanır ve yönetilir.

## 🚀 Özellikler

- 📷 Kamera veya galeri üzerinden görsel yükleme
- 🧠 YOLOv8 ile görselden otomatik ürün tanıma
- 🤖 Manuel Stok Kontrolü
- 🔄 Firebase Firestore ile stok takibi ve güncelleme
- 🔐 Firebase Authentication ile kullanıcı doğrulama
- 🌐 Flask API ile model tahmin servisi

## 🎯 Proje Amacı

SmartStock, özellikle küçük marketler ve bireysel kullanıcılar için barkodsuz ürünlerin bile otomatik olarak sayılabildiği, kullanıcı dostu bir stok kontrol sistemi sunar. RFID gibi pahalı sistemlere alternatif olarak geliştirilmiştir.

## 🧱 Kullanılan Teknolojiler

| Teknoloji     | Açıklama                                              |
|---------------|--------------------------------------------------------|
| Flutter       | Mobil uygulama arayüzü (Android)                      |
| Firebase      | Authentication, Firestore (veri saklama), Storage    |
| YOLOv8        | Görsel tabanlı nesne tanıma modeli                   |
| Roboflow      | Veri kümesi etiketleme ve model eğitimi ortamı       |
| Flask         | Python tabanlı API sunucusu                          |
| Figma         | UI/UX tasarımı                                        |

## 🧪 Sistem Performansı

- 🎯 **Model doğruluğu:** mAP@50: 92.8%, Precision: 92.4%, Recall: 92.2%
- ⚡ Gerçek Android cihazda test edildi
- 🏪 Süpermarket ortamında kullanıcı testleri yapıldı
- 🌥 Işık değişimlerine karşı dayanıklı tespit yeteneği

## 🔧 Kurulum

1. Reposu klonlayın:
   ```bash
   git clone https://github.com/kullaniciadi/SmartStock.git
   cd SmartStock
   
2. Python API için ortamı kur:
   cd backend
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   export $(cat .env | xargs)
   python app/app.py

3. Flutter tarafı için:
   cd frontend
   flutter pub get
   flutter run


## 📁 Proje Yapısı

```
SmartStock/
├── backend/            # Flask API & YOLOv8 modeli
│   ├── app.py
│   ├── model/          # Eğitimli YOLOv8 ağırlıkları
│   └── utils/          # Görüntü işleme yardımcıları
│
├── frontend/           # Flutter mobil uygulama
│   ├── lib/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── requirements.txt    # Flask API bağımlılıkları
└── README.md           # Proje tanıtım dosyası 
```

## 👥 Ekip Üyeleri
- [Aleyna Keskin](https://github.com/Aleynakeskinn)
- [Mustafa Karagöz](https://github.com/MustafaKaragz)

-Danışman: [Dr. Necip Gökhan Kasapoğlu]


