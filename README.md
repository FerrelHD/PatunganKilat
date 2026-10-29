# ⚡ PatunganKilat

<p align="center">
  <img src="web/icons/Icon-512.png" alt="PatunganKilat Logo" width="120" style="border-radius: 28px;" />
</p>

<p align="center">
  <strong>Bagi Tagihan Tanpa Drama.</strong><br/>
  Modern, Gen-Z styled Neobank Split Bill PWA built with Flutter.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Web%20%7C%20PWA%20%7C%20Android%20%7C%20iOS-22c55e" alt="Platform" />
  <img src="https://img.shields.io/badge/State%20Management-Riverpod-blueviolet" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Design-Neobank%20Dark%20%26%20Lime-C5F536?labelColor=141518" alt="Design Theme" />
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License" />
</p>

---

## 📖 About The Project

Patungan saat nongkrong, makan bareng, atau pesta seringkali bikin pusing: hitungan pajak resto (PB1 10%), biaya *service charge*, diskon promo GoFood/GrabFood yang rumit, porsi makan yang beda-beda, sampai drama nagih transferan ke rekening atau e-wallet.

**PatunganKilat** hadir sebagai aplikasi web progresif (PWA) bergaya **Neobank Fintech modern** (perpaduan warna *Midnight Dark* `#141518` dan *Electric Lime* `#C5F536`). Dirancang untuk menyederhanakan perhitungan patungan dalam hitungan detik—lengkap dengan pemindaian struk otomatis berbasis AI, pembagian porsi proporsional, serta opsi pembayaran ganda Bank dan E-Wallet.

---

## ✨ Fitur Unggulan (Key Features)

### 🧾 1. Smart Receipt OCR Scanner (OCR Engine 2)
- **Scan Struk dari Kamera atau Galeri**: Ekstrak nama makanan, jumlah pesanan (*quantity*), dan harga satuan secara instan.
- **Dukungan Struk Multi-Baris Khas Indonesia**: Mengenali format struk kasir/POS (Solaria, Mie Gacoan, Moka, Pawoon, GoFood/GrabFood) di mana nama menu berada di baris pertama dan rincian `Qty x Harga` berada di baris kedua.
- **Deteksi Otomatis Pajak & Service**: Menangkap nominal PB1/PPN dan Service Charge langsung dari struk.
- **Layar Review & Quick Edit**: Edit salah eja nama atau harga dari struk fisik, tambah menu manual yang terlewat, dan sesuaikan kuantitas sebelum dimasukkan ke arena.
- **Opsi Tempel Teks (Paste Mode)**: Salin rincian pesanan dari aplikasi *food delivery* dan ekstrak langsung.

### ⚡ 2. Split Arena & Atur Porsi Bebas Ribet
- **1-Tap Bagi Rata**: Cukup tap nama teman untuk membagi rata tagihan suatu menu secara instan.
- **Atur Porsi Fleksibel**: Ada teman yang makan 2 porsi atau cuma icip sedikit? Gunakan stepper inline sederhana `[ - ] [ + ]` untuk pembagian proporsional yang adil tanpa kalkulasi fraksi yang membingungkan.
- **Dukungan Pajak, Service, & Promo**: Toggle pajak (10%), service charge (5%), dan diskon promo voucher yang otomatis didistribusikan proporsional ke setiap orang.

### 💳 3. Dual Payment Options (Bank & E-Wallet)
- **Rekening Bank Utama**: Mendukung BCA, Mandiri, BRI, BNI, Jago, SeaBank, BCA Digital (blu), CIMB Niaga, Permata, dll.
- **E-Wallet Opsional**: Teman lebih suka bayar via e-wallet? Sediakan opsi GoPay, OVO, DANA, atau ShopeePay dalam satu layar.
- **1-Tap Copy to Clipboard**: Nomor rekening dan nomor e-wallet dapat disalin langsung dengan sekali sentuh.

### 📲 4. WhatsApp Billing & Download Bukti PNG
- **Kirim Rincian ke WhatsApp**: Format pesan WhatsApp siap kirim yang rapi, mencantumkan total per orang, menu yang dimakan, serta detail transfer Bank & E-Wallet.
- **Unduh Bukti Gambar Struk**: Render tampilan struk digital neobank menjadi gambar PNG untuk dibagikan ke grup chat atau Instagram Story.

### 🔔 5. Apple Dynamic Island NeoToast
- Notifikasi mengambang di bagian atas layar dengan animasi *spring physics* elastis, bingkai *glass hairline*, dan kontras *pitch black* yang nyaman di mata.

### 📱 6. PWA Ready & Responsive
- Dapat di-*Add to Home Screen* di iOS (Safari) dan Android (Chrome) selayaknya aplikasi *native*.
- Tampilan responsif dengan *notch handling* bersih tanpa blur status bar.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Channel Stable, Web & Mobile)
- **Language**: [Dart](https://dart.dev)
- **State Management**: [Riverpod 2.x](https://riverpod.dev) (`StateNotifier`, `Provider`)
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts) (`Plus Jakarta Sans` & `JetBrains Mono`)
- **OCR Engine**: OCR.space API (Engine 2 dengan optimasi tabel dan receipt)
- **Image & File Handling**: `image_picker`, `file_saver`
- **Testing**: Full unit testing & widget testing suite

### Struktur Direktori:
```text
lib/
├── core/
│   ├── theme/          # AppColors (Dark & Lime), AppTypography
│   ├── utils/          # CurrencyFormatter, ReceiptGenerator
│   └── widgets/        # NeoToast, NeoPillButton, NeoCards
├── features/
│   ├── bill_engine/    # State management, split calculation algorithm, models
│   ├── home/           # Zero-state, hero banner, payment info setup
│   ├── onboarding/     # Intro screen & splash persistence
│   ├── receipt/        # Digital receipt summary, PNG export, WhatsApp share
│   └── split_arena/    # Split Arena, menu items, portion split sheet, OCR scanner
└── main.dart
```

---

## 🚀 Memulai (Getting Started)

### Prasyarat
- Flutter SDK (>= 3.5.0)
- Dart SDK (>= 3.5.0)
- Google Chrome atau browser modern apa saja

### Instalasi & Menjalankan Aplikasi

1. **Clone repository:**
   ```bash
   git clone https://github.com/FerrelHD/PatunganKilat.git
   cd PatunganKilat
   ```

2. **Pasang dependensi:**
   ```bash
   flutter pub get
   ```

3. **Jalankan di browser (Chrome):**
   ```bash
   flutter run -d chrome
   ```

4. **Jalankan automated tests:**
   ```bash
   flutter test
   ```

5. **Build release untuk Web (PWA):**
   ```bash
   flutter build web --release
   ```

---

## 📄 Lisensi (License)

Didistribusikan di bawah lisensi MIT. Lihat `LICENSE` untuk informasi lebih lanjut.

---

<p align="center">
  Dibuat dengan ⚡ untuk memudahkan patungan tanpa drama!
</p>
