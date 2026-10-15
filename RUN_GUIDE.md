# Panduan Menjalankan PatunganKilat di Komputer Lokal

Dokumen ini menjelaskan cara menjalankan aplikasi **PatunganKilat** di komputer lokalmu.

---

## 1. Menambahkan Flutter ke Environment PATH

Jika terminal belum mengenali perintah `flutter`, jalankan perintah PowerShell ini (cukup sekali saja):

```powershell
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";E:\flutter\bin",
    "User"
)
```

Setelah itu, tutup dan buka kembali jendela terminal/PowerShell kamu.

---

## 2. Inisialisasi Dependensi & Platform Support

Di folder proyek `E:\College Stuff\Career\PatunganKilat`, jalankan:

```powershell
# 1. Download paket-paket yang dibutuhkan (Riverpod, Google Fonts, Phosphor, dll)
flutter pub get

# 2. Buat file platform pendukung (Web, Android, Windows)
flutter create . --platforms=web,android
```

---

## 3. Menjalankan Unit Test (Verifikasi Kalkulasi Proporsional)

Untuk memastikan rumus bagi rata, proporsi pajak PB1, diskon, dan rounding reconciliation berjalan 100% akurat:

```powershell
flutter test
```

---

## 4. Cara Menjalankan Aplikasi di Local

Ada 2 cara yang sangat direkomendasikan:

### Cara A: Preview di Google Chrome (Paling Cepat & Ringan di RAM)
Cocok untuk pengembangan dan belajar karena tidak membebani RAM laptop:

```powershell
flutter run -d chrome
```

**Tips Tampilan Mobile di Chrome:**
1. Setelah jendela Chrome terbuka, tekan tombol **F12** (buka Developer Tools).
2. Tekan kombinasi tombol **Ctrl + Shift + M** (mengaktifkan *Device Toolbar*).
3. Di dropdown atas, pilih dimensi **iPhone 14 Pro** atau **Pixel 7**.
4. Kamu akan melihat aplikasi tampil persis di dalam layar smartphone dengan responsivitas penuh!

---

### Cara B: Langsung di HP Android Fisik via USB (Paling Realistis)
Cocok untuk merasakan sensasi sentuhan asli, mengetes *Drag-and-Drop*, dan fitur *Share Struk ke WhatsApp*:

1. Hubungkan HP Android ke laptop menggunakan kabel USB.
2. Di HP kamu, aktifkan **Developer Options** (Opsi Pengembang) lalu nyalakan **USB Debugging**.
3. Cek apakah HP sudah terdeteksi dengan perintah:
   ```powershell
   flutter devices
   ```
4. Jalankan aplikasi ke HP:
   ```powershell
   flutter run
   ```
   Aplikasi akan langsung terpasang dan terbuka di layar HP kamu lengkap dengan fitur **Hot Reload** (cukup tekan `r` di terminal setiap kali kamu mengubah kode, perubahan langsung muncul seketika di HP!).
