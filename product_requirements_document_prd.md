# Product Requirements Document (PRD): PatunganKilat

## 1. Gambaran Umum Produk (Product Overview)
* **Nama Produk:** PatunganKilat
* **Tagline:** Visual Bill Splitter Tanpa Drama.
* **Platform:** Mobile (iOS & Android) — dibangun dengan **Flutter**.
* **Tipe Aplikasi:** Offline-First Utility App (Tanpa perlu registrasi/login).
* **Gaya Visual:** Clean Neobank Aesthetics (Pure White Cards, Matte Black Pills, & Acid Lime Accents).
* **Visi Produk:** Mengubah proses hitung-hitungan patungan nongkrong yang kaku dan membosankan menjadi pengalaman visual setara aplikasi *fintech* modern yang interaktif, cepat, dan menghasilkan rincian tagihan (*Struk Card*) estetik siap kirim ke grup WhatsApp.

---

## 2. Latar Belakang Masalah (Problem Statement)
1. **Kerumitan Biaya Tambahan & Diskon:** Tagihan restoran atau pesanan makanan *online* hampir selalu memuat biaya tambahan bertingkat (Service Charge 5–7%, PB1 10%, biaya bungkus/ongkir) serta diskon promo dengan batas maksimal (misal: Diskon 50% maks. Rp30.000).
2. **Inefisiensi Hitung Manual:** Membagi rata biaya tambahan atau diskon secara pukul rata tidak adil bagi teman yang hanya memesan menu murah. Sebaliknya, menghitung proporsi manual dengan kalkulator memakan waktu dan rawan salah hitung.
3. **Friksi Penagihan:** Mengetik rincian tagihan satu per satu di grup chat dan mengirim nomor rekening secara terpisah membuat informasi mudah tenggelam di *chat*.

---

## 3. Target Pengguna & User Persona
* **Si Tukang Talangin (Primary User):** Orang yang membayar tagihan kasir terlebih dahulu atau memesan lewat aplikasi ojol, lalu bertugas menghitung porsi bayaran tiap teman.
* **Kebutuhan Utama:** Kecepatan input (selesai di bawah 2 menit), akurasi distribusi pajak/diskon hingga rupiah terakhir, serta kemudahan melampirkan rekening/QRIS di satu gambar struk yang rapi.

---

## 4. Fitur Utama & Spesifikasi Fungsional (MVP Scope)

### A. Home & Manajemen Rekening Talangan (Screen 1)
* **Ringkasan Talangan Aktif:** Menampilkan total nominal sesi patungan yang sedang berlangsung dengan fitur *hide/show nominal* (ikon mata) dan tombol utama **"Buat Patungan Kilat"**.
* **Kartu Rekening Talangan (Your Cards):**
  * Menyimpan daftar rekening bank (BCA, Mandiri, SeaBank, dll.) dan E-Wallet (GoPay, OVO, Dana) di penyimpanan lokal.
  * Mendukung penyimpanan 1 gambar QRIS dari galeri HP pengguna.
  * Tombol pintas **"Salin"** nomor rekening sekali ketuk.
* **Riwayat Patungan (Recent Sessions):** Daftar sesi patungan sebelumnya lengkap dengan indikator status (`Aktif`, `Lunas`, dan jumlah orang).

### B. Interactive Split Arena (Screen 2)
* **Pemilih Partisipan (Horizontal Friend Cards):**
  * Barisan kartu teman di bagian atas layar.
  * Kartu teman yang sedang aktif dipilih memiliki *thick outline ring* hitam (`2px solid #141518`) sebagai target *tap* atau *drop* item makanan.
  * Menampilkan total tagihan *real-time* milik masing-masing teman.
* **Kontrol Komponen Proporsional Otomatis:**
  * Toggle & editor cepat untuk **Pajak PB1** (default 10%), **Service Charge** (default 5%), dan **Diskon Promo / Ojol** (dalam nominal Rupiah).
* **Daftar Menu Interaktif (Tap & Drag-and-Drop):**
  * Pengguna dapat menambahkan menu baru (`Nama Menu`, `Harga Total`, dan `Ikon Emoji`).
  * **Dual Interaction Mode:** Pengguna bisa melakukan *Drag-and-Drop* kartu makanan ke kartu teman di atas, ATAU cukup memilih kartu teman lalu melakukan *Tap* pada daftar menu di bawahnya untuk mempercepat alokasi satu tangan.
  * **Menu Sharing (Multi-Assign):** Satu menu (misal: *Chicken Karaage Sharing*) dapat di-*assign* ke beberapa orang sekaligus, dan harganya otomatis terbagi rata ke orang-orang yang ditandai pada menu tersebut.
  * Tombol pintas **"Bagi Rata Semua"** untuk membagi seluruh daftar menu ke semua partisipan secara instan.

### C. Mesin Kalkulator Proporsional Otomatis (Calculation Engine)
Rumus perhitungan untuk setiap individu ($i$) dari total keseluruhan tagihan:

1. **Subtotal Menu Individu ($S_i$):** Jumlah harga menu (atau pecahan menu *sharing*) yang diambil oleh orang ke-$i$.
2. **Total Subtotal Semua Menu ($S_{\text{total}}$):**
   $$S_{\text{total}} = \sum_{i=1}^{n} S_i$$
3. **Rasio Proporsi Individu ($R_i$):**
   $$R_i = \frac{S_i}{S_{\text{total}}}$$
4. **Distribusi Pajak, Service, & Diskon Proporsional:**
   * $\text{Pajak Individu } (P_i) = (\text{Total PB1} + \text{Total Service} + \text{Biaya Lain}) \times R_i$
   * $\text{Diskon Individu } (D_i) = \text{Total Diskon Promo} \times R_i$
5. **Tagihan Bersih Individu ($\text{Final}_i$):**
   $$\text{Final}_i = \max(0, S_i + P_i - D_i)$$

### D. One-Tap Struk Card & WhatsApp Export (Screen 3)
* **Thermal Receipt Visual Card:**
  * Menampilkan *header badge* tempat makan, tanggal transaksi, dan nama pembuat talangan.
  * Merinci porsi per orang: Nama, persentase proporsi ($\%$), daftar menu yang dipesan, rincian subtotal + pajak - diskon, dan **Nominal Akhir** di dalam *badge* warna Acid Lime.
  * Menampilkan ringkasan perhitungan total di bagian bawah serta boks informasi transfer rekening/QRIS.
  * Bagian bawah kartu memiliki bentuk gerigi struk kasir (*jagged thermal receipt edge*).
* **Dual Export Action:**
  * **Share Image Struk:** Mengubah widget struk menjadi gambar PNG beresolusi tajam menggunakan `RepaintBoundary` dan membagikannya ke WhatsApp melalui `share_plus`.
  * **Copy Format Teks WA:** Menyalin ringkasan teks berformat *bold* & *monospace* WhatsApp ke *clipboard*.

---

## 5. Arsitektur Teknis & Stack Flutter
* **Framework:** Flutter (Dart 3.x)
* **State Management:** `flutter_riverpod` (StateNotifier / Notifier untuk reaktivitas kalkulasi *real-time*).
* **Local Storage:** `shared_preferences` atau `hive_ce` (Menyimpan riwayat sesi, preset teman, dan daftar rekening talangan).
* **Packages Utama:**
  * `google_fonts` (`Plus Jakarta Sans` & `JetBrains Mono`)
  * `phosphor_flutter` (Set ikon konsisten dengan gaya *bold* dan *fill*)
  * `share_plus` & `path_provider` (Ekspor dan bagikan gambar struk)
  * `intl` (Format mata uang Rupiah `Rp 331.650`)

---

## 6. Batasan MVP (Out of Scope Fase 1)
* **Tanpa Login / Autentikasi:** Aplikasi langsung terbuka ke *Home Dashboard* dalam 1 detik.
* **Tanpa Payment Gateway:** Aplikasi tidak memproses uang asli; penyelesaian pembayaran dilakukan via transfer bank/QRIS masing-masing pengguna.
* **OCR Struk Kamera (Ditunda ke V1.1):** Fokus MVP adalah kecepatan input manual & *tap/drag assignment* tanpa friksi koreksi salah baca OCR.