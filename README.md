# TRASI - Sistem Pemantauan Kualitas Air

TRASI adalah aplikasi mobile berbasis Flutter yang dirancang untuk pemantauan kualitas air secara real-time di tambak udang. Aplikasi ini terintegrasi dengan sensor IoT untuk memvisualisasikan parameter penting seperti pH, suhu, Salinitas, dan kekeruhan, membantu pengguna menjaga kondisi optimal untuk akuakultur.

## 🌟 Fitur Utama

- **Dasbor Real-time**: Pemantauan langsung sensor kualitas air.
- **Visualisasi Data**: Grafik interaktif untuk analisis data historis menggunakan `fl_chart`.
- **Sistem Peringatan**: Notifikasi otomatis untuk tingkat kualitas air yang kritis (Baik, Waspada, Kritis).
- **Manajemen Multi-Tambak**: Dukungan untuk memantau beberapa tambak dan perangkat.
- **Lokalisasi**: Dilokalkan sepenuhnya untuk pengguna Indonesia (`id_ID`).

## 🛠️ Teknologi yang Digunakan

- **Framework**: Flutter (Dart)
- **Manajemen State**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- **Backend**: Firebase (Realtime Database, Authentication)
- **Grafik**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Lokasi**: [geolocator](https://pub.dev/packages/geolocator)
- **Pemformatan**: [intl](https://pub.dev/packages/intl)

## 🚀 Memulai

### Prasyarat

- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Proyek Firebase

### Instalasi

1. **Kloning repositori**
   ```bash
   git clone https://github.com/Diaz1401/S5_App trasi
   cd trasi
   ```

2. **Instal dependensi**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Firebase**
   - Pastikan file `google-services.json` ditempatkan di dalam folder `android/app/`.
   - Proyek ini menggunakan `firebase_options.dart` untuk konfigurasi.
   - Kunjungi [dokumentasi setup Firebase](https://firebase.google.com/docs/flutter/setup) untuk info lebih lanjut.

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## 📂 Struktur Proyek

```
lib/
├── main.dart           # Titik masuk & inisialisasi aplikasi
├── app.dart            # Widget root & pengaturan tema
└── src/
    ├── models/         # Model data (WaterQualitySample, Pond, dll.)
    ├── providers/      # Provider Riverpod (Manajemen State)
    ├── screens/        # Layar UI (Dasbor, Grafik, Peringatan)
    ├── services/       # Layanan eksternal (API, Notifikasi)
    ├── theme/          # Tema aplikasi
    └── widgets/        # Komponen UI yang dapat digunakan kembali
```

## 🔧 Konfigurasi

Aplikasi ini terhubung ke Firebase Realtime Database.
- **Jalur Data**: `sensorData/$deviceId/realtime`
- **Otentikasi**: Saat ini dikonfigurasi untuk akses admin (lihat `sensor_rtdb_provider.dart`).
