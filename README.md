# SELF VOLTA: Sistem Manajemen Kehidupan Mandiri Anak Kos

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Offline--First%20Single%20State-007A78)](#arsitektur-teknis)
[![Tests](https://img.shields.io/badge/Tests-313%20Passing-success)](test/)
[![Release](https://img.shields.io/badge/Release-v1.3.1-emerald)](https://github.com/voltakyy/self-volta/releases/tag/v1.3.1)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> Aplikasi pendamping hidup mandiri berbasis Flutter yang dirancang spesifik untuk realitas hidup anak kos: anggaran kiriman bulanan yang ketat, keterbatasan alat masak kamar (panci listrik & rice cooker), siklus air galon 19L, latihan fisik tanpa alat di kamar sempit, serta sinkronisasi ritme harian (jadwal sholat, waktu belajar, dan perkiraan cuaca).

---

## Daftar Isi
1. [Manifesto & Latar Belakang Masalah](#1-manifesto--latar-belakang-masalah)
2. [Arsitektur Teknis & Prinsip Offline-First](#2-arsitektur-teknis--prinsip-offline-first)
3. [Modul Keuangan: Manajemen Kas & Limit Harian Dinamis](#3-modul-keuangan-manajemen-kas--limit-harian-dinamis)
4. [Buku Kas & Alokasi Target Impian (Piano Fund)](#4-buku-kas--alokasi-target-impian-piano-fund)
5. [Modul Planning Makanan: Filosofi Dapur 48:9 & Paket A–G](#5-modul-planning-makanan-filosofi-dapur-489--paket-ag)
6. [Eksekusi Resep: Panci Listrik ([PL]) & Magic Com ([MC])](#6-eksekusi-resep-panci-listrik-pl--magic-com-mc)
7. [Checklist Belanja Pasar & Manajemen Bahan Basah](#7-checklist-belanja-pasar--manajemen-bahan-basah)
8. [Modul Hidrasi: Siklus Galon 19L & Target Air Harian](#8-modul-hidrasi-siklus-galon-19l--target-air-harian)
9. [Modul Latihan Fisik: Calisthenics Kamar Kos Tanpa Alat](#9-modul-latihan-fisik-calisthenics-kamar-kos-tanpa-alat)
10. [Form Panduan Gerakan & Interval Pemulihan Otot](#10-form-panduan-gerakan--interval-pemulihan-otot)
11. [Modul Waktu & Sholat: Sinkronisasi Astronomis Lokal](#11-modul-waktu--sholat-sinkronisasi-astronomis-lokal)
12. [Modul Cuaca: Integrasi Open-Meteo & Indeks Jemuran Kos](#12-modul-cuaca-integrasi-open-meteo--indeks-jemuran-kos)
13. [Modul Study & Produktivitas: Siklus Fokus Pomodoro](#13-modul-study--produktivitas-siklus-fokus-pomodoro)
14. [Modul To-Do & Kebiasaan: Daily Discipline & XP Leveling](#14-modul-to-do--kebiasaan-daily-discipline--xp-leveling)
15. [Modul Booster: Recovery Nutrisi Murah & Pertolongan Pertama](#15-modul-booster-recovery-nutrisi-murah--pertolongan-pertama)
16. [Sistem Alarm & Notifikasi: Background Scheduler Offline](#16-sistem-alarm--notifikasi-background-scheduler-offline)
17. [Integritas Data: Fail-Safe Recovery & Cadangan sv_v1_bak](#17-integritas-data-fail-safe-recovery--cadangan-sv_v1_bak)
18. [Desain Visual Editorial: Tipografi Manrope & Bento Surface](#18-desain-visual-editorial-tipografi-manrope--bento-surface)
19. [Standar Pengujian: 313 Tes Otomatis & Audit Responsif](#19-standar-pengujian-313-tes-otomatis--audit-responsif)
20. [Panduan Instalasi, Build APK, & Kontribusi](#20-panduan-instalasi-build-apk--kontribusi)

---

## 1. Manifesto & Latar Belakang Masalah

Kehidupan anak kos di kota perantauan memiliki dinamika yang sangat spesifik dan jarang dijawab dengan tepat oleh aplikasi produktivitas umum:

- **Aplikasi budgeting konvensional** terlalu rumit dengan puluhan kategori akun bank, kartu kredit, dan investasi saham yang tidak relevan bagi mahasiswa atau perantau yang mengandalkan satu sumber uang saku bulanan.
- **Aplikasi resep kuliner umum** mengasumsikan ketersediaan dapur lengkap (kompor 2 tungku, oven, blender, kulkas 2 pintu), padahal anak kos hanya memiliki stopkontak 450-900 VA, satu panci listrik serbaguna, dan rice cooker kecil.
- **Aplikasi fitness komersial** menuntut langganan gym bulanan atau alat dumbbell, mengabaikan fakta bahwa ruang gerak kamar kos seringkali hanya berukuran 2×3 meter.
- **Aplikasi jadwal harian** menuntut koneksi internet terus-menerus dan pendaftaran akun berbasis email/password yang rentan pelacakan data, padahal sinyal di dalam kamar kos sering tidak stabil dan kuota internet seluler terbatas.

**SELF VOLTA** hadir sebagai solusi terpadu, 100% offline-first, tanpa iklan, dan tanpa tracking. Fokus utamanya adalah mempertahankan ritme hidup sehat, menjaga keuangan tetap aman hingga akhir bulan, dan memaksimalkan efisiensi energi seorang anak kos.
