# Design System & UI Specification: PatunganKilat

Dokumen ini merupakan panduan visual dan spesifikasi komponen UI untuk membangun aplikasi Flutter **PatunganKilat**. Seluruh estetika mengacu pada gaya **Clean Neobank Fintech** (permukaan *off-white* lembut, kartu putih bersih dengan *border radius* besar, tombol *pill* hitam pekat, dan aksen *Electric Acid Lime*).

---

## 1. Filosofi Visual (Design Philosophy)
1. **High Contrast, Low Clutter:** Menggunakan latar belakang abu-abu dingin yang sangat lembut (`#F5F6F8`) agar kartu putih murni (`#FFFFFF`) terlihat menonjol tanpa memerlukan garis tepi (*border*) tebal atau bayangan (*drop shadow*) yang kotor.
2. **Acid Lime sebagai Visual Anchor:** Warna hijau neon kekuningan (`#C5F536`) hanya digunakan pada elemen berprioritas tinggi: kartu rekening utama, *badge* total harga per orang, status aktif, dan indikator interaktif.
3. **Tactile & Pill-Shaped:** Tombol aksi utama selalu berbentuk kapsul penuh (*full pill button*) berwarna hitam pekat (`#141518`) dengan teks putih atau aksen ikon Acid Lime.

---

## 2. Palet Warna (Color Tokens)

Gunakan konstanta warna berikut di dalam `AppColors` (`lib/core/theme/app_colors.dart`):

| Token Name | Hex Code | Flutter Color | Penggunaan Utama |
| :--- | :--- | :--- | :--- |
| `neoBg` | `#F5F6F8` | `Color(0xFFF5F6F8)` | `Scaffold` background utama di seluruh layar |
| `neoCard` | `#FFFFFF` | `Color(0xFFFFFFFF)` | Permukaan kartu utama, item list, dan kertas struk |
| `neoDark` | `#141518` | `Color(0xFF141518)` | Teks utama, tombol CTA *pill*, kartu tema gelap, *active ring* |
| `neoLime` | `#C5F536` | `Color(0xFFC5F536)` | Aksen utama, kartu rekening BCA, *badge* nominal akhir |
| `neoLimeDark` | `#9ED115` | `Color(0xFF9ED115)` | Teks diskon/potongan harga di atas latar putih |
| `neoMuted` | `#8A8F9E` | `Color(0xFF8A8F9E)` | Teks sekunder, label tanggal, *subtitle*, ikon tidak aktif |
| `neoSoft` | `#EEF0F4` | `Color(0xFFEEF0F4)` | Background tombol sekunder, *chip* inaktif, *input field* |
| `neoBorder` | `#0D141518` | `Color(0x0D141518)` | Garis tipis kartu (`Colors.black.withOpacity(0.05)`) |

---

## 3. Tipografi (Typography System)

Menggunakan kombinasi dua jenis huruf dari paket `google_fonts`:
1. **Primary UI Font (`Plus Jakarta Sans`):** Digunakan untuk seluruh judul, nama menu, label tombol, dan sapaan pengguna. Memiliki karakter geometris modern yang bersih.
2. **Numeric & Receipt Font (`JetBrains Mono`):** Digunakan khusus untuk angka nominal harga item, nomor rekening (`•••• 8821`), persentase, dan rincian angka di dalam kertas struk agar sejajar sempurna.

### Skala Tipografi Flutter (`TextTheme`)
* **Hero Balance / Total Talangan:** `Plus Jakarta Sans`, `28sp`, `FontWeight.w800`, `letterSpacing: -0.5`, warna `neoDark`.
* **Screen Title / AppBar:** `Plus Jakarta Sans`, `15sp`, `FontWeight.w800`, warna `neoDark`.
* **Section Heading:** `Plus Jakarta Sans`, `14sp`, `FontWeight.w800`, warna `neoDark`.
* **Card Title / Menu Name:** `Plus Jakarta Sans`, `12sp–13sp`, `FontWeight.w800`, warna `neoDark`.
* **Body / Subtitle:** `Plus Jakarta Sans`, `11sp`, `FontWeight.w500`, warna `neoMuted`.
* **Monospace Price / Account Number:** `JetBrains Mono`, `12sp`, `FontWeight.w700`, warna `neoDark`.

---

## 4. Dimensi, Radius, & Elevasi (Layout & Shapes)

* **Outer Card Border Radius:** `28.0` (`BorderRadius.circular(28)`) untuk kontainer besar seperti kartu Total Talangan, Riwayat Patungan, dan Struk Kasir.
* **Inner Item / Bank Card Radius:** `20.0` hingga `26.0` untuk baris menu makanan dan kartu rekening horizontal.
* **Primary CTA Button Radius:** `999.0` (`StadiumBorder` / *Full Pill*).
* **Soft Shadow Specification:**
  ```dart
  BoxShadow(
    color: const Color(0xFF141518).withOpacity(0.04),
    blurRadius: 24,
    offset: const Offset(0, 8),
    spreadRadius: -4,
  )
  ```

---

## 5. Spesifikasi Pola & Komponen Khas (Signature Patterns)

### A. Kartu "Acid Lime" dengan Watermark Tipografi (`NeoLimeCard`)
Terinspirasi dari kartu debit `N.NEO` pada referensi desain:
* **Background:** Warna dasar `neoLime` (`#C5F536`).
* **Pattern Overlay:** Teks berulang `"PATUNGAN.KILAT.PATUNGAN.KILAT."` menggunakan `FontWeight.w800`, ukuran `22sp`, warna `Colors.white.withOpacity(0.42)`, memenuhi latar kartu dengan `ClipRRect`.
* **Konten:** Nama Bank di kiri atas (`BCA.`), *badge* hitam dengan teks hijau (`QRIS Ready`) di kanan atas, nomor rekening *masked* di kiri bawah, dan tombol kapsul putih `Salin` di kanan bawah.

### B. Kartu Pemilih Teman di Split Arena (`FriendTargetCard`)
* Berbentuk *grid* 4 kolom atau *horizontal list* dengan tinggi `84px` dan radius `20px`.
* **State Aktif (Selected / Drop Target):** Memiliki `Border.all(color: AppColors.neoDark, width: 2.0)` dan sedikit efek *scale up* (`1.03x`).
* Menampilkan lingkaran inisial nama di kiri atas, nama panggilan, serta total tagihan sementara dalam format ringkas (`Rp 86rb`).

### C. Baris Menu Makanan Interaktif (`MenuItemTile`)
* Tinggi dinamis dengan `padding: EdgeInsets.all(12)` dan `BorderRadius.circular(20)`.
* **Kiri:** Kotak ikon emoji berukuran `40x40` dengan radius `16px`. Jika menu di-*assign* ke teman yang sedang aktif, warna latar kotak ikon berubah menjadi `neoLime` (`#C5F536`).
* **Tengah:** Nama makanan (`w800`), harga format Rupiah (`JetBrains Mono`), dan deretan *mini pill badges* berisi nama teman-teman yang memesan menu tersebut.
* **Kanan:** Lingkaran indikator status berukuran `28x28` (ikon `+` abu-abu jika belum dipilih, berubah menjadi lingkaran `neoDark` dengan ikon centang `neoLime` jika sudah dipilih).

### D. Kertas Struk Kasir Bergerigi (`ThermalReceiptCard`)
* Menggunakan kontainer putih bersih dengan bagian atas membulat `BorderRadius.vertical(top: Radius.circular(28))`.
* Pemisah antar-seksi menggunakan garis putus-putus horizontal (`CustomPainter` *dashed line* warna `Colors.black12`).
* **Ujung Bawah Bergerigi (Jagged Edge):** Menggunakan `CustomClipper<Path>` atau deretan segitiga berulang selebar `16px` dan tinggi `12px` di bagian paling bawah kartu untuk memberikan siluet kertas struk kasir asli saat diekspor menjadi gambar lewat `RepaintBoundary`.

---

## 6. Rincian Tata Letak Per Layar (Screen-by-Screen Specs)

### Layar 1: Home & Rekening Talangan
1. **Top Bar:** Sapaan `"Malam, [Nama] 👋"` + subteks `"Siap talangin tongkrongan?"` di kiri; tombol lonceng notifikasi berlatar putih dengan titik indikator `neoLime` di kanan.
2. **Hero Balance Card:** Menampilkan label `"Total Talangan Aktif"`, *badge* sesi aktif, nominal besar `Rp 331.650`, tombol *toggle visibility* (mata), dan tombol kapsul hitam penuh **"+ Buat Patungan Kilat"**.
3. **Horizontal Carousel "Rekening Talangan":** Menampilkan kartu Acid Lime (BCA) dan kartu Matte Black (GoPay) yang bisa digeser ke samping.
4. **Card "Riwayat Patungan":** Daftar sesi patungan sebelumnya dengan ikon emoji tempat makan, waktu, jumlah orang, total tagihan, dan *pill badge* status berwarna `neoLime` untuk sesi yang masih aktif.
5. **Bottom Navigation Bar:** 4 tab bersih (`Home`, `Split Bill`, `Teman`, `Struk`) dengan efek *blur* tipis (`BackdropFilter`).

### Layar 2: Interactive Split Arena
1. **Custom AppBar:** Tombol *back* bulat putih di kiri, judul tempat makan & instruksi singkat di tengah, tombol `+` bulat hitam berikon `neoLime` di kanan untuk menambah menu baru.
2. **Section 1 — Pilih / Drop ke Teman:** Baris kartu teman yang berfungsi ganda sebagai pemilih target *Tap* sekaligus `DragTarget<MenuItem>`.
3. **Section 2 — Komponen Proporsional Otomatis:** Kartu putih berisi 3 tombol *toggle* berdampingan:
   * `Pajak PB1 (10% ON/OFF)`
   * `Service (5% ON/OFF)`
   * `Diskon Ojol (-Rp 30rb)`
4. **Section 3 — Daftar Menu:** Daftar kartu makanan yang dibungkus dengan widget `Draggable<MenuItem>` dan `GestureDetector` (untuk *Tap-to-Assign*).
5. **Sticky Bottom Bar:** Menampilkan `Total Bersih (+Pajak -Diskon)` secara *real-time* dan tombol *pill* hitam **"Lihat Struk & QRIS →"**.

### Layar 3: One-Tap Struk Card & Export
1. **Top Action Bar:** Label status, judul `"Struk Patungan"`, dan tombol kapsul kecil `"Copy WA"` berwarna `neoLime`.
2. **Profile-Style Header Badge:** Lingkaran besar (`80x80`) di tengah atas dengan pola `neoLime` dan ikon tempat makan, dilengkapi lencana kecil berikon struk di pojok kanan bawahnya.
3. **RepaintBoundary Struk Area:**
   * Daftar rincian per orang di dalam kotak abu-abu lembut (`#F5F6F8`), menampilkan persentase proporsi, nama menu (termasuk pecahan *sharing* seperti `1/4`), rincian `Menu`, `+Pajak`, `-Diskon`, dan nominal akhir di dalam *badge* `neoLime`.
   * Ringkasan total tagihan di bagian kaki struk.
   * Kotak informasi **Transfer Rekening / QRIS** lengkap dengan tombol `"Salin"`.
   * Penutup gerigi kertas struk di bagian paling bawah.
4. **Sticky Bottom Bar:** Tombol kapsul hitam penuh berikon WhatsApp hijau neon **"Share Struk ke WA"**.