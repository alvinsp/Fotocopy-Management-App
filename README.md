# 🖨️ Fotocopy Management System (FMS)

Aplikasi manajemen antrean dan laporan keuangan real-time untuk toko fotocopy keluarga yang telah beroperasi selama 20 tahun di Bekalan. Dibangun dengan fokus pada kecepatan operasional dan transparansi data keuangan harian.

## 🚀 Fitur Utama

- **Real-time Dashboard:** Pantau antrean yang masuk dan ubah status transaksi (Menunggu -> Selesai) secara instan.
- **Financial Reporting:** Laporan omzet otomatis yang dikelompokkan berdasarkan kategori (Fotocopy, Print, Jilid, ATK).
- **Date Filtering:** Pilih tanggal spesifik untuk melihat riwayat transaksi dan pendapatan di masa lalu.
- **Smart Search:** Pencarian nama pelanggan yang cepat untuk memudahkan operator saat antrean ramai.
- **Secure Admin Access:** Login sistem untuk memastikan hanya pengelola toko yang bisa memodifikasi data keuangan.

## 🛠️ Tech Stack

- **Framework:** Flutter (Material 3)
- **State Management:** BLoC (Business Logic Component)
- **Backend:** Firebase Firestore (Real-time DB) & Firebase Auth
- **Architecture:** Clean Architecture (Data, Logic, Presentation Layers)
- **Security:** Environment Variables (.env) & Firestore Security Rules

## 🛡️ Keamanan & Privasi

Proyek ini menggunakan `.env` untuk menyembunyikan API Keys sensitif dan telah menerapkan Firestore Security Rules untuk mencegah akses data tanpa otorisasi.

## 📸 Tampilan Aplikasi

_(Tips: Masukkan screenshot aplikasi kamu di sini nanti)_

---

_Developed with ❤️ to modernize a 20-year legacy business._
