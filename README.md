# O&C Financial Tracker 👩‍❤️‍👨✨

> *"Mengukir jejak finansial berdua, satu catatan cinta pada satu waktu."*

![Flutter](https://img.shields.io/badge/Built_with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Powered_by-Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Riverpod](https://img.shields.io/badge/State-Riverpod-1A202C?style=for-the-badge)

## 📖 Deskripsi
**O&C Financial** adalah aplikasi pencatatan keuangan pribadi *Full-Stack* yang dirancang secara khusus dan eksklusif untuk pasangan. Berangkat dari pencatatan manual menggunakan tabel _Spreadsheet_, aplikasi ini dievolusikan menjadi aplikasi *Mobile* dengan performa mutakhir, integrasi *database Cloud Real-time*, dan dibalut dengan desain antarmuka (*UI*) *Flat & Romantic Minimalist* bernuansa Scandinavian modern. 

Tinggalkan cara lama berdebat soal "Uang ini bayar pakai rekening siapa?". O&C mencatat Pemasukan Gabungan, Jajan individu, Pengeluaran berdua, hingga riwayat Jejak yang saling bersinergi ke HP masing-masing pengguna tanpa lemot!

## ✨ Fitur Unggulan

*   ☁️ **Cloud Synchronization:** Data langsung *auto-sync* antara dua _device_ secara seketika (*Real-time*). Terima kasih, Supabase PostgreSQL!
*   🎨 **Aesthetic Custom Engine:** Kustomisasi kecerahan latar (Opacity) & Warna-warni _Wallpaper Gradient_ (*Built-in SharedPreferences*). Bisa unggah kenangan _(Image Gallery)_ langsung dari Handphone!
*   📊 **Analitik & Donut Chart:** Analisa Pengeluaran (*fl_chart*) secara cerdas berdasar kerangka Waktu Spesifik (Minggu Ini, Bulan Ini, dan Tahun Sepanjang). 
*   🔮 **Glassmorphism UI/UX:** Atap menu Blur (*Frosted Glass Appbar*), Pop-up modal "Bawah", Ikon dinamis Deteksi Pria/Wanita (*Auto Gender Detection Avatar*).
*   🚀 **Smooth Optimistic-CRUD:** Animasi *"Slide-to-Delete"* tanpa efek kedip (_Zero Blink State_), form update/edit reaktif anti kaku.

---

## 📸 Sketsa Antarmuka (Screenshots)
*(Opsional: Anda bisa *Upload/Drag n Drop* gambar tangkapan layar HP/Emulator Anda di bawah tulisan ini untuk mempercantik Portofolio Github ini)*

| Jejak Kita (Beranda) | Input Brankas Baru (Form) | Sketsa Cerita (Analitik Grafik) |
| :---: | :---: | :---: |
| [ Gambar 1 ] | [ Gambar 2 ] | [ Gambar 3 ] |

---

## 💻 Teknologi di Balik Layar

*   **Frontend Framework:** Flutter (Dart)
*   **State Management:** Flutter Riverpod (V2 - *AsyncNotifier*)
*   **Backend & Database:** Supabase (PostgreSQL - *Serverless API*)
*   **Formating & Security:** `intl` (Rupiah Regex & Time id_ID), `flutter_dotenv` (API Vaulting)

## 🛠️ Cara Menginstall & Menjalankan (Bagi Pengembang Lain)

Ingin mengintip dan menjalankan aplikasi cinta ini di Laptop/Mesin Anda? Ikuti petunjuk berikut:

**1. Persiapkan Environment Variabel (.env) 🔐**
Keamanan adalah prioritas. Repository ini tidak men-publish kunci ke database sungguhan kami. Anda harus menyiapkannya. Buat sebuah file bernama `.env` (tanpa tanda kutip) pada akar *directory project* sejajar dengan `pubspec.yaml`, isilah:
```env
SUPABASE_URL=Isi_dengan_url_projek_supabase_anda
SUPABASE_KEY=Isi_dengan_kunci_anon_projek_supabase_anda
```

2. Sinkronkan Plugin & Paket Dependensi Buka Terminal/Console, eksekusi
penyatuan tulang punggung App ini:

```
flutter clean
flutter pub get
```

3. Nyalakan ke Layar Android / Emulator Kalian!
```
flutter run
```

Untuk mengompile atau membuat App (Mesin Cetak Ringan) yang siap dipasang,
eksekusikan build:

```
flutter build apk --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
```

📐 Skema Basis Data Dasar

Aplikasi berdiri dengan desain rasional 3 meja (Tables) saling berelasi Foreign
Key (UUID) pada Server PostgreSQL:

  - users: Menyimpan id Pasangan Individu atau Rekening Gabungan (Oman / Ceca /
    O&C).
  - categories: Opsi Jenis Keperluan Alokasi (Tagihan, Makan Berdua, Liburan
    dll).
  - transactions: Meja catatan utama pencatat Waktu dan Nominal Math. (Rp).

(Created and Crafted with 💙 and ☕️ for Oman & Ceca)