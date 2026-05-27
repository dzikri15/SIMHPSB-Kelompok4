-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 27, 2026 at 10:20 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `simhpsb_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `alerts`
--

CREATE TABLE `alerts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `komoditas` varchar(255) NOT NULL,
  `stok_saat_ini` int(11) NOT NULL,
  `batas_minimum` int(11) NOT NULL,
  `status` enum('aktif','proses','dalam_penanganan','selesai') NOT NULL DEFAULT 'aktif',
  `catatan` text DEFAULT NULL,
  `ditangani_oleh` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `alerts`
--

INSERT INTO `alerts` (`id`, `komoditas`, `stok_saat_ini`, `batas_minimum`, `status`, `catatan`, `ditangani_oleh`, `created_at`, `updated_at`) VALUES
(1, 'Beras', 400, 500, 'selesai', NULL, 2, '2026-05-25 10:07:55', '2026-05-25 13:54:58'),
(2, 'Gabah', 1200, 800, 'selesai', NULL, 2, '2026-05-25 10:07:55', '2026-05-25 13:53:55'),
(3, 'Gabah', 0, 1000, 'selesai', 'Stok turun di bawah batas minimum', NULL, '2026-05-25 13:54:51', '2026-05-26 04:44:21'),
(4, 'Gabah', 0, 1000, 'selesai', 'Stok turun di bawah batas minimum', 1, '2026-05-26 04:44:32', '2026-05-26 04:46:10'),
(5, 'Gabah', 0, 1000, 'selesai', 'Stok turun di bawah batas minimum', 1, '2026-05-26 04:47:39', '2026-05-27 05:06:13'),
(6, 'Beras', -8800, 400, 'selesai', 'Stok turun di bawah batas minimum', 1, '2026-05-26 10:46:16', '2026-05-26 10:49:15'),
(7, 'Beras', -1108800, 400, 'selesai', 'Stok turun di bawah batas minimum', 1, '2026-05-26 13:18:28', '2026-05-27 05:06:10'),
(8, 'Jagung', -1000, 1000, 'aktif', 'Stok turun di bawah batas minimum', NULL, '2026-05-27 05:25:40', '2026-05-27 05:25:40'),
(9, 'Beras', -1108900, 400, 'aktif', 'Stok turun di bawah batas minimum', NULL, '2026-05-27 05:26:54', '2026-05-27 05:26:54'),
(10, 'Gabah', 500, 1000, 'aktif', 'Stok turun di bawah batas minimum', NULL, '2026-05-27 08:00:38', '2026-05-27 08:00:38');

-- --------------------------------------------------------

--
-- Table structure for table `alert_configurations`
--

CREATE TABLE `alert_configurations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `batas_min_beras` int(11) NOT NULL DEFAULT 200,
  `batas_min_gabah` int(11) NOT NULL DEFAULT 500,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `alert_configurations`
--

INSERT INTO `alert_configurations` (`id`, `batas_min_beras`, `batas_min_gabah`, `created_at`, `updated_at`) VALUES
(1, 400, 1000, '2026-05-26 04:44:53', '2026-05-26 04:45:34');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `distribusi`
--

CREATE TABLE `distribusi` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `gudang_id` bigint(20) UNSIGNED NOT NULL,
  `jumlah_distribusi` decimal(10,2) NOT NULL,
  `tujuan` varchar(255) NOT NULL,
  `tanggal_distribusi` date NOT NULL,
  `catatan` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `distribusi`
--

INSERT INTO `distribusi` (`id`, `gudang_id`, `jumlah_distribusi`, `tujuan`, `tanggal_distribusi`, `catatan`, `created_at`, `updated_at`) VALUES
(1, 1, 250.00, 'Pasar Kota A', '2026-05-20', 'Distribusi kebutuhan mingguan', '2026-05-25 10:07:55', '2026-05-25 10:07:55'),
(2, 2, 150.00, ' Distributor Lokal', '2026-05-21', 'Distribusi cadangan', '2026-05-25 10:07:55', '2026-05-25 10:07:55');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gudang`
--

CREATE TABLE `gudang` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nama_gudang` varchar(255) NOT NULL,
  `lokasi` text NOT NULL,
  `kapasitas` decimal(10,2) NOT NULL,
  `status` enum('aktif','maintenance','tidak_aktif') NOT NULL DEFAULT 'aktif',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `gudang`
--

INSERT INTO `gudang` (`id`, `nama_gudang`, `lokasi`, `kapasitas`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Gudang Sentral', 'Kota A', 5000.00, 'aktif', '2026-05-25 10:07:55', '2026-05-25 10:07:55'),
(2, 'Gudang Cabang', 'Kota B', 3000.00, 'aktif', '2026-05-25 10:07:55', '2026-05-25 10:07:55');

-- --------------------------------------------------------

--
-- Table structure for table `harga`
--

CREATE TABLE `harga` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `komoditas` varchar(255) NOT NULL,
  `harga_per_kg` decimal(10,2) NOT NULL,
  `tanggal_berlaku` date NOT NULL,
  `sumber` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `harga`
--

INSERT INTO `harga` (`id`, `komoditas`, `harga_per_kg`, `tanggal_berlaku`, `sumber`, `created_at`, `updated_at`) VALUES
(1, 'Beras', 4500.00, '2026-05-20', 'Pasar Tradisional', '2026-05-25 10:07:55', '2026-05-25 10:07:55'),
(2, 'Gabah', 3200.00, '2026-05-20', 'Pasar Lokal', '2026-05-25 10:07:55', '2026-05-25 10:07:55');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `konfigurasi_harga`
--

CREATE TABLE `konfigurasi_harga` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `harga_beli_gabah` decimal(15,2) NOT NULL,
  `ongkos_giling` decimal(15,2) NOT NULL,
  `harga_jual_beras` decimal(15,2) NOT NULL,
  `rasio_konversi` decimal(5,2) NOT NULL,
  `berlaku_mulai` date NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lahan`
--

CREATE TABLE `lahan` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `petani_id` bigint(20) UNSIGNED NOT NULL,
  `nama_lahan` varchar(255) NOT NULL,
  `luas` decimal(8,2) NOT NULL,
  `lokasi` text NOT NULL,
  `jenis_tanah` enum('sawah','ladang','kebun') NOT NULL DEFAULT 'sawah',
  `status` enum('aktif','tidak_aktif') NOT NULL DEFAULT 'aktif',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `lahan`
--

INSERT INTO `lahan` (`id`, `petani_id`, `nama_lahan`, `luas`, `lokasi`, `jenis_tanah`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Lahan Sawah A', 1.20, 'Dusun Tengah', 'sawah', 'aktif', '2026-05-25 10:07:55', '2026-05-25 10:07:55'),
(2, 2, 'Lahan Sawah B', 2.00, 'Dusun Selatan', 'sawah', 'aktif', '2026-05-25 10:07:55', '2026-05-25 10:07:55');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_04_18_043143_add_role_to_users_table', 1),
(5, '2026_04_18_044851_create_alerts_table', 1),
(6, '2026_05_12_003844_create_petani_table', 1),
(7, '2026_05_12_003919_create_lahan_table', 1),
(8, '2026_05_12_003946_create_panen_table', 1),
(9, '2026_05_12_004012_create_gudang_table', 1),
(10, '2026_05_12_004033_create_stok_beras_table', 1),
(11, '2026_05_12_004048_create_harga_table', 1),
(12, '2026_05_12_004102_create_distribusi_table', 1),
(13, '2026_05_16_000000_add_petani_columns', 1),
(14, '2026_05_21_000001_alter_stok_beras_tanggal_to_datetime', 1),
(15, '2026_05_21_063952_create_konfigurasi_harga_table', 1),
(16, '2026_05_22_000000_add_petani_id_to_users_table', 1),
(17, '2026_05_22_100000_add_transaksi_columns_to_stok_beras', 1),
(18, '2026_05_23_000001_add_transaction_columns_to_stok_beras_table', 2),
(19, '2026_05_24_000001_add_musim_to_panen_table', 2),
(20, '2026_05_24_000002_create_alert_configurations_table', 2),
(21, '2026_05_24_000003_update_alerts_table_add_catatan_and_status_enum', 2);

-- --------------------------------------------------------

--
-- Table structure for table `panen`
--

CREATE TABLE `panen` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `lahan_id` bigint(20) UNSIGNED NOT NULL,
  `tanggal_panen` date NOT NULL,
  `jumlah_gabah` decimal(10,2) NOT NULL,
  `harga_gabah_per_kg` decimal(10,2) DEFAULT NULL,
  `konversi_beras` decimal(10,2) DEFAULT NULL,
  `musim` varchar(255) DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `panen`
--

INSERT INTO `panen` (`id`, `lahan_id`, `tanggal_panen`, `jumlah_gabah`, `harga_gabah_per_kg`, `konversi_beras`, `musim`, `catatan`, `created_at`, `updated_at`) VALUES
(28, 1, '2026-05-27', 500.00, NULL, 100.00, NULL, NULL, '2026-05-27 07:46:46', '2026-05-27 07:46:46'),
(29, 2, '2026-05-27', 500.00, NULL, 55.00, 'Apr-Sep 2025', 'Komoditas: Padi.', '2026-05-27 07:47:22', '2026-05-27 07:47:22'),
(30, 2, '2026-05-27', 500.00, NULL, 275.00, NULL, NULL, '2026-05-27 07:47:35', '2026-05-27 07:47:35'),
(31, 2, '2026-05-27', 600.00, NULL, 55.00, 'Okt-Mar 2024/2025', 'Komoditas: Padi.', '2026-05-27 07:48:22', '2026-05-27 07:48:22'),
(32, 2, '2026-05-27', 600.00, NULL, 55.00, 'Okt-Mar 2025/2026', 'Komoditas: Padi.', '2026-05-27 07:49:37', '2026-05-27 07:49:37'),
(33, 2, '2026-05-27', 5000.00, NULL, 2745.00, 'Okt-Mar 2024/2025', 'Komoditas: Padi.', '2026-05-27 07:53:01', '2026-05-27 07:53:01'),
(34, 2, '2026-05-27', 1000.00, NULL, 615.00, 'Okt-Mar 2024/2025', 'Komoditas: Padi.', '2026-05-27 07:57:48', '2026-05-27 07:57:48');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `petani`
--

CREATE TABLE `petani` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nama` varchar(255) NOT NULL,
  `nik` varchar(32) DEFAULT NULL,
  `alamat` text NOT NULL,
  `catatan` text DEFAULT NULL,
  `no_hp` varchar(255) DEFAULT NULL,
  `telepon` varchar(50) DEFAULT NULL,
  `luas_lahan` int(10) UNSIGNED DEFAULT NULL,
  `komoditas` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `petani`
--

INSERT INTO `petani` (`id`, `nama`, `nik`, `alamat`, `catatan`, `no_hp`, `telepon`, `luas_lahan`, `komoditas`, `email`, `tanggal_lahir`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Pak Budi', '3201010101010001', 'Desa Sawah, Kecamatan A', 'Petani padi organik', '081234567890', '0211234567', 2, 'beras', 'petani1@simhpsb.com', '1980-05-12', 'aktif', '2026-05-25 10:07:55', '2026-05-25 10:07:55'),
(2, 'Bu Sari', '3201010101010002', 'Desa Sawah, Kecamatan B', 'Petani lokal', '082345678901', '0217654321', 2, 'beras', 'petani2@simhpsb.com', '1985-08-20', 'aktif', '2026-05-25 10:07:55', '2026-05-25 10:07:55');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('8cLkuEgvTBKBBKh9exu4g9gdmadxeHuEvRDaBxK3', 1, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.121.0 Chrome/142.0.7444.265 Electron/39.8.8 Safari/537.36', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoiNUVMbnJFQ3pNZVZBeFI1VU10UWc1bEFkeWhVbE1PTUgxZnFCZ1hGdyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzQ6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9hZG1pbi9wZXRhbmkiO3M6NToicm91dGUiO3M6MTg6ImFkbWluLnBldGFuaS5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==', 1779707085),
('rivmSlQFiqVxdCFR5HtpldeHSlZih6BAV6q9lJxR', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.121.0 Chrome/142.0.7444.265 Electron/39.8.8 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTEZORWszNlU1c3A4VFdBSEg3aDJrWlpDbnVpWmtHaVE5eUlnU0hXcSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjc6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9sb2dpbiI7czo1OiJyb3V0ZSI7czo1OiJsb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1779714510);

-- --------------------------------------------------------

--
-- Table structure for table `stok_beras`
--

CREATE TABLE `stok_beras` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `gudang_id` bigint(20) UNSIGNED NOT NULL,
  `jenis_transaksi` enum('masuk','keluar') NOT NULL DEFAULT 'masuk',
  `komoditas` varchar(50) NOT NULL DEFAULT 'Beras',
  `jumlah` decimal(10,2) NOT NULL DEFAULT 0.00,
  `keterangan` text DEFAULT NULL,
  `saldo_setelah` decimal(10,2) DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `jumlah_stok` decimal(10,2) NOT NULL,
  `batas_minimum` decimal(10,2) NOT NULL DEFAULT 1000.00,
  `tanggal_update` datetime DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stok_beras`
--

INSERT INTO `stok_beras` (`id`, `gudang_id`, `jenis_transaksi`, `komoditas`, `jumlah`, `keterangan`, `saldo_setelah`, `user_id`, `jumlah_stok`, `batas_minimum`, `tanggal_update`, `catatan`, `created_at`, `updated_at`) VALUES
(18, 1, 'masuk', 'Beras', 100.00, 'mbg', NULL, 1, 100.00, 1000.00, '2026-05-27 14:57:00', NULL, '2026-05-27 07:58:08', '2026-05-27 07:58:08'),
(19, 1, 'masuk', 'Gabah', 500.00, 'mbg', NULL, NULL, 500.00, 0.00, '2026-05-27 00:00:00', NULL, '2026-05-27 08:00:38', '2026-05-27 08:00:38');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'admin',
  `petani_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`, `role`, `petani_id`) VALUES
(1, 'Admin SIMHPSB', 'admin@simhpsb.com', NULL, '$2y$12$RSmkdUcFo82TVzsYZvGP2O8.tp9zyc.KWBnYEVrPRof5tbA8khTSO', NULL, '2026-05-25 10:07:53', '2026-05-25 10:07:54', 'admin', NULL),
(2, 'Petugas SIMHPSB', 'petugas@simhpsb.com', NULL, '$2y$12$U58NBG3Ag76aCkWELZM6j.eSJZ6vx9b8RbgjZD5hgv9g2rBS9Iozm', NULL, '2026-05-25 10:07:54', '2026-05-25 10:07:54', 'petugas', NULL),
(3, 'Petani SIMHPSB', 'petani@simhpsb.com', NULL, '$2y$12$OhhvSXszgsof6mYIND.UfuABBL39d31slFRMEsMdsWRoPCDUS/pIK', NULL, '2026-05-25 10:07:54', '2026-05-25 10:07:55', 'petani', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alerts`
--
ALTER TABLE `alerts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `alerts_ditangani_oleh_foreign` (`ditangani_oleh`);

--
-- Indexes for table `alert_configurations`
--
ALTER TABLE `alert_configurations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `distribusi`
--
ALTER TABLE `distribusi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `distribusi_gudang_id_foreign` (`gudang_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `gudang`
--
ALTER TABLE `gudang`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `harga`
--
ALTER TABLE `harga`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `konfigurasi_harga`
--
ALTER TABLE `konfigurasi_harga`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `lahan`
--
ALTER TABLE `lahan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lahan_petani_id_foreign` (`petani_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `panen`
--
ALTER TABLE `panen`
  ADD PRIMARY KEY (`id`),
  ADD KEY `panen_lahan_id_foreign` (`lahan_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `petani`
--
ALTER TABLE `petani`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `stok_beras`
--
ALTER TABLE `stok_beras`
  ADD PRIMARY KEY (`id`),
  ADD KEY `stok_beras_gudang_id_foreign` (`gudang_id`),
  ADD KEY `stok_beras_user_id_foreign` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD KEY `users_petani_id_foreign` (`petani_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alerts`
--
ALTER TABLE `alerts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `alert_configurations`
--
ALTER TABLE `alert_configurations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `distribusi`
--
ALTER TABLE `distribusi`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `gudang`
--
ALTER TABLE `gudang`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `harga`
--
ALTER TABLE `harga`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `konfigurasi_harga`
--
ALTER TABLE `konfigurasi_harga`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lahan`
--
ALTER TABLE `lahan`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `panen`
--
ALTER TABLE `panen`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `petani`
--
ALTER TABLE `petani`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `stok_beras`
--
ALTER TABLE `stok_beras`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alerts`
--
ALTER TABLE `alerts`
  ADD CONSTRAINT `alerts_ditangani_oleh_foreign` FOREIGN KEY (`ditangani_oleh`) REFERENCES `users` (`id`);

--
-- Constraints for table `distribusi`
--
ALTER TABLE `distribusi`
  ADD CONSTRAINT `distribusi_gudang_id_foreign` FOREIGN KEY (`gudang_id`) REFERENCES `gudang` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `lahan`
--
ALTER TABLE `lahan`
  ADD CONSTRAINT `lahan_petani_id_foreign` FOREIGN KEY (`petani_id`) REFERENCES `petani` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `panen`
--
ALTER TABLE `panen`
  ADD CONSTRAINT `panen_lahan_id_foreign` FOREIGN KEY (`lahan_id`) REFERENCES `lahan` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `stok_beras`
--
ALTER TABLE `stok_beras`
  ADD CONSTRAINT `stok_beras_gudang_id_foreign` FOREIGN KEY (`gudang_id`) REFERENCES `gudang` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `stok_beras_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_petani_id_foreign` FOREIGN KEY (`petani_id`) REFERENCES `petani` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
