-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 24, 2026 at 02:16 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.30

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
  `id` bigint UNSIGNED NOT NULL,
  `komoditas` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `stok_saat_ini` int NOT NULL,
  `batas_minimum` int NOT NULL,
  `status` enum('aktif','proses','dalam_penanganan','selesai') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'aktif',
  `catatan` text COLLATE utf8mb4_unicode_ci,
  `ditangani_oleh` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `alerts`
--

INSERT INTO `alerts` (`id`, `komoditas`, `stok_saat_ini`, `batas_minimum`, `status`, `catatan`, `ditangani_oleh`, `created_at`, `updated_at`) VALUES
(1, 'Beras', 400, 500, 'selesai', NULL, 1, '2026-05-22 10:59:21', '2026-05-24 04:20:16'),
(2, 'Gabah', 1200, 800, 'selesai', NULL, 2, '2026-05-22 10:59:21', '2026-05-24 05:58:14'),
(3, 'Beras', 200, 400, 'aktif', 'Stok turun di bawah batas minimum', NULL, '2026-05-24 06:17:02', '2026-05-24 06:17:02'),
(4, 'Gabah', 200, 1000, 'aktif', 'Stok turun di bawah batas minimum', NULL, '2026-05-24 06:17:02', '2026-05-24 06:17:02');

-- --------------------------------------------------------

--
-- Table structure for table `alert_configurations`
--

CREATE TABLE `alert_configurations` (
  `id` bigint UNSIGNED NOT NULL,
  `batas_min_beras` int NOT NULL DEFAULT '200',
  `batas_min_gabah` int NOT NULL DEFAULT '500',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `alert_configurations`
--

INSERT INTO `alert_configurations` (`id`, `batas_min_beras`, `batas_min_gabah`, `created_at`, `updated_at`) VALUES
(1, 400, 1000, '2026-05-24 02:51:07', '2026-05-24 02:51:07');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `distribusi`
--

CREATE TABLE `distribusi` (
  `id` bigint UNSIGNED NOT NULL,
  `gudang_id` bigint UNSIGNED NOT NULL,
  `jumlah_distribusi` decimal(10,2) NOT NULL,
  `tujuan` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tanggal_distribusi` date NOT NULL,
  `catatan` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `distribusi`
--

INSERT INTO `distribusi` (`id`, `gudang_id`, `jumlah_distribusi`, `tujuan`, `tanggal_distribusi`, `catatan`, `created_at`, `updated_at`) VALUES
(1, 1, 250.00, 'Pasar Tradisional Majalengka', '2026-05-15', 'Distribusi rutin minggu 1', '2026-05-22 10:59:21', '2026-05-22 10:59:21'),
(2, 2, 150.00, 'Koperasi Desa', '2026-05-15', 'Distribusi ke outlet partner', '2026-05-22 10:59:21', '2026-05-22 10:59:21');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gudang`
--

CREATE TABLE `gudang` (
  `id` bigint UNSIGNED NOT NULL,
  `nama_gudang` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lokasi` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `kapasitas` decimal(10,2) NOT NULL,
  `status` enum('aktif','maintenance','tidak_aktif') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'aktif',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `gudang`
--

INSERT INTO `gudang` (`id`, `nama_gudang`, `lokasi`, `kapasitas`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Gudang Sentral', 'Pusat Kota Majalengka', 5000.00, 'aktif', '2026-05-22 10:59:21', '2026-05-22 10:59:21'),
(2, 'Gudang Cabang', 'Samping Jalan Raya', 3000.00, 'aktif', '2026-05-22 10:59:21', '2026-05-22 10:59:21');

-- --------------------------------------------------------

--
-- Table structure for table `harga`
--

CREATE TABLE `harga` (
  `id` bigint UNSIGNED NOT NULL,
  `komoditas` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `harga_per_kg` decimal(10,2) NOT NULL,
  `tanggal_berlaku` date NOT NULL,
  `sumber` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `harga`
--

INSERT INTO `harga` (`id`, `komoditas`, `harga_per_kg`, `tanggal_berlaku`, `sumber`, `created_at`, `updated_at`) VALUES
(1, 'Beras', 4500.00, '2026-05-01', 'Pasar Lokal Majalengka', '2026-05-22 10:59:21', '2026-05-22 10:59:21'),
(2, 'Gabah', 3200.00, '2026-05-01', 'Supplier Petani Lokal', '2026-05-22 10:59:21', '2026-05-22 10:59:21');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `konfigurasi_harga`
--

CREATE TABLE `konfigurasi_harga` (
  `id` bigint UNSIGNED NOT NULL,
  `harga_beli_gabah` decimal(15,2) NOT NULL,
  `ongkos_giling` decimal(15,2) NOT NULL,
  `harga_jual_beras` decimal(15,2) NOT NULL,
  `rasio_konversi` decimal(5,2) NOT NULL,
  `berlaku_mulai` date NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `konfigurasi_harga`
--

INSERT INTO `konfigurasi_harga` (`id`, `harga_beli_gabah`, `ongkos_giling`, `harga_jual_beras`, `rasio_konversi`, `berlaku_mulai`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 760000.00, 700.00, 14500.00, 62.00, '2026-05-01', 1, '2026-05-22 10:59:21', '2026-05-24 02:25:58');

-- --------------------------------------------------------

--
-- Table structure for table `lahan`
--

CREATE TABLE `lahan` (
  `id` bigint UNSIGNED NOT NULL,
  `petani_id` bigint UNSIGNED NOT NULL,
  `nama_lahan` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `luas` decimal(8,2) NOT NULL,
  `lokasi` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `jenis_tanah` enum('sawah','ladang','kebun') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'sawah',
  `status` enum('aktif','tidak_aktif') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'aktif',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `lahan`
--

INSERT INTO `lahan` (`id`, `petani_id`, `nama_lahan`, `luas`, `lokasi`, `jenis_tanah`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Lahan Sawah A', 1.20, 'Kawasan Barat Desa Gunung Manik', 'sawah', 'aktif', '2026-05-22 10:59:21', '2026-05-22 10:59:21'),
(2, 2, 'Lahan Sawah B', 2.00, 'Kawasan Timur Desa Cisarua', 'sawah', 'aktif', '2026-05-22 10:59:21', '2026-05-22 10:59:21');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2026_05_23_000001_add_transaction_columns_to_stok_beras_table', 1),
(2, '2026_05_24_000001_add_musim_to_panen_table', 2),
(3, '2026_05_24_000002_create_alert_configurations_table', 3),
(4, '2026_05_24_000003_update_alerts_table_add_catatan_and_status_enum', 4);

-- --------------------------------------------------------

--
-- Table structure for table `panen`
--

CREATE TABLE `panen` (
  `id` bigint UNSIGNED NOT NULL,
  `lahan_id` bigint UNSIGNED NOT NULL,
  `tanggal_panen` date NOT NULL,
  `jumlah_gabah` decimal(10,2) NOT NULL,
  `harga_gabah_per_kg` decimal(10,2) DEFAULT NULL,
  `konversi_beras` decimal(10,2) DEFAULT NULL,
  `musim` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `catatan` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `panen`
--

INSERT INTO `panen` (`id`, `lahan_id`, `tanggal_panen`, `jumlah_gabah`, `harga_gabah_per_kg`, `konversi_beras`, `musim`, `catatan`, `created_at`, `updated_at`) VALUES
(1, 1, '2026-05-10', 1200.00, 3200.00, 720.00, NULL, 'Panen musim pertama', '2026-05-22 10:59:21', '2026-05-22 10:59:21'),
(2, 2, '2026-05-12', 1500.00, 3200.00, 900.00, NULL, 'Panen musim pertama', '2026-05-22 10:59:21', '2026-05-22 10:59:21'),
(3, 2, '2026-05-23', 199.00, NULL, 61.50, NULL, 'Komoditas: Padi. Musim: Okt-Mar 2025/2026.', '2026-05-23 14:58:38', '2026-05-23 14:58:38'),
(4, 1, '2026-05-24', 200.00, NULL, 61.50, 'Okt-Mar 2025/2026', 'Komoditas: Jagung.', '2026-05-24 01:50:55', '2026-05-24 01:50:55');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `petani`
--

CREATE TABLE `petani` (
  `id` bigint UNSIGNED NOT NULL,
  `nama` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nik` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alamat` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `catatan` text COLLATE utf8mb4_unicode_ci,
  `no_hp` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telepon` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `status` enum('aktif','nonaktif') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'aktif',
  `luas_lahan` int UNSIGNED DEFAULT NULL,
  `komoditas` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `petani`
--

INSERT INTO `petani` (`id`, `nama`, `nik`, `alamat`, `catatan`, `no_hp`, `telepon`, `email`, `tanggal_lahir`, `status`, `luas_lahan`, `komoditas`, `created_at`, `updated_at`) VALUES
(1, 'Pak Budi Santoso', '3201010101010001', 'Desa Gunung Manik, Kec. Majalengka', NULL, NULL, '081234567890', 'budi@simhpsb.com', NULL, 'aktif', 1, 'Jagung', '2026-05-22 10:59:21', '2026-05-24 03:01:13'),
(2, 'Bu Siti Aisyah', '3201010101010002', 'Desa Cisarua, Kec. Majalengka', NULL, '082345678901', '082345678901', 'siti@simhpsb.com', '2003-01-17', 'aktif', 2, 'Padi & Jagung', '2026-05-22 10:59:21', '2026-05-24 02:29:41'),
(4, 'Muhammad Dzikri Sagara', '3201234567890003', 'cipaera', NULL, NULL, '085603738266', NULL, NULL, 'aktif', 12, 'Padi', '2026-05-24 06:19:38', '2026-05-24 06:19:38');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stok_beras`
--

CREATE TABLE `stok_beras` (
  `id` bigint UNSIGNED NOT NULL,
  `gudang_id` bigint UNSIGNED NOT NULL,
  `jenis_transaksi` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `komoditas` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jumlah` decimal(10,2) DEFAULT NULL,
  `keterangan` text COLLATE utf8mb4_unicode_ci,
  `jumlah_stok` decimal(10,2) NOT NULL,
  `batas_minimum` decimal(10,2) NOT NULL DEFAULT '1000.00',
  `tanggal_update` datetime NOT NULL,
  `catatan` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user_id` bigint UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stok_beras`
--

INSERT INTO `stok_beras` (`id`, `gudang_id`, `jenis_transaksi`, `komoditas`, `jumlah`, `keterangan`, `jumlah_stok`, `batas_minimum`, `tanggal_update`, `catatan`, `created_at`, `updated_at`, `user_id`) VALUES
(1, 1, NULL, NULL, NULL, NULL, 1200.00, 1000.00, '2026-05-15 10:30:00', 'Stok beras siap distribusi', '2026-05-22 10:59:21', '2026-05-22 10:59:21', NULL),
(2, 2, NULL, NULL, NULL, NULL, 400.00, 800.00, '2026-05-15 10:30:00', 'Stok beras cadangan', '2026-05-22 10:59:21', '2026-05-22 10:59:21', NULL),
(3, 1, 'keluar', 'Beras', 200.00, 'MBG Dapur 2 dzikri', -200.00, 1000.00, '2026-05-24 09:07:00', NULL, '2026-05-24 02:07:46', '2026-05-24 02:07:46', 1),
(4, 1, 'masuk', 'Beras', 200.00, 'dzikri', 0.00, 1000.00, '2026-05-24 09:19:00', NULL, '2026-05-24 02:20:19', '2026-05-24 02:20:19', 1),
(5, 1, 'masuk', 'Beras', 200.00, 'dzikri', 200.00, 1000.00, '2026-05-24 09:20:00', NULL, '2026-05-24 02:21:00', '2026-05-24 02:21:00', 1),
(6, 1, 'masuk', 'Gabah', 200.00, 'dzikri', 200.00, 1000.00, '2026-05-24 09:26:00', NULL, '2026-05-24 02:26:56', '2026-05-24 02:26:56', 1),
(7, 1, 'masuk', 'Beras', 6000.00, 'rei', 6200.00, 1000.00, '2026-05-24 09:27:00', NULL, '2026-05-24 02:28:10', '2026-05-24 02:28:10', 1),
(8, 1, 'masuk', 'Gabah', 3000.00, 'Budi', 3200.00, 1000.00, '2026-05-24 12:30:00', NULL, '2026-05-24 05:30:54', '2026-05-24 05:30:54', 1),
(9, 1, 'masuk', 'Gabah', 3000.00, 'Alam', 6200.00, 1000.00, '2026-05-24 12:31:00', NULL, '2026-05-24 05:31:56', '2026-05-24 05:31:56', 1),
(10, 1, 'keluar', 'Gabah', 6000.00, 'MBG Dapur 1 fahri', 200.00, 1000.00, '2026-05-24 12:35:00', NULL, '2026-05-24 05:35:58', '2026-05-24 05:35:58', 1),
(11, 1, 'keluar', 'Beras', 7000.00, 'Toko Barokah difa', -800.00, 1000.00, '2026-05-24 12:36:00', NULL, '2026-05-24 05:36:53', '2026-05-24 05:36:53', 1),
(12, 1, 'keluar', 'Beras', 7000.00, 'MBG Dapur 2 difa', -7800.00, 1000.00, '2026-05-24 12:36:00', NULL, '2026-05-24 05:37:41', '2026-05-24 05:37:41', 1),
(13, 1, 'keluar', 'Beras', 5000.00, 'MBG Dapur 2 difa', -5800.00, 1000.00, '2026-05-24 12:36:00', NULL, '2026-05-24 05:39:12', '2026-05-24 05:39:12', 1),
(14, 1, 'keluar', 'Beras', 5000.00, 'MBG Dapur 1 difa', -5800.00, 1000.00, '2026-05-24 12:36:00', NULL, '2026-05-24 05:39:54', '2026-05-24 05:39:54', 1),
(15, 1, 'masuk', 'Beras', 1000.00, 'silvy', 200.00, 1000.00, '2026-05-24 12:58:00', NULL, '2026-05-24 05:59:29', '2026-05-24 05:59:29', 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'admin',
  `petani_id` bigint UNSIGNED DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `role`, `petani_id`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Admin SIMHPSB', 'admin@simhpsb.com', NULL, '$2y$12$3TOsXdxzcCbNZGa2O9d/Hupfo7tp237ca8i7cNIWRCR0PfMLFg8h6', 'admin', NULL, NULL, '2026-05-22 10:59:21', '2026-05-23 12:39:03'),
(2, 'Petugas SIMHPSB', 'petugas@simhpsb.com', NULL, '$2y$12$hUsDvHOAAn1wUqEqj50eremhX82gOImSq7BJhQ8dirOG6qIHblqrm', 'petugas', NULL, NULL, '2026-05-22 10:59:21', '2026-05-24 03:20:06'),
(3, 'siti', 'siti@simhpsb.com', NULL, '$2y$12$5LolHNWCwpkfdMe0tyRl9eRH3T7rL5JCtqa2ieyxISJ5TFPYOdRCq', 'petani', 2, NULL, '2026-05-22 10:59:21', '2026-05-23 14:26:08'),
(4, 'Silvy Halimatusyadiah', 'silvy@simhpsb.com', NULL, '$2y$12$xsF7GcOU1LnsfoJsSxiOf.UchgKfLSn4C7Hcpy//Ymi5PjHiQDddK', 'admin', NULL, NULL, '2026-05-23 14:24:25', '2026-05-23 14:24:25'),
(6, 'budi', 'budi@simhpsb.com', NULL, '$2y$12$lXRKXd8JlUsTtqYvlcYGNOvst1JA/qiPqvQx05aZWIG1GWbmO58CK', 'petani', 1, NULL, '2026-05-24 03:25:11', '2026-05-24 03:25:11');

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
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD KEY `idx_users_petani_id` (`petani_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alerts`
--
ALTER TABLE `alerts`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `alert_configurations`
--
ALTER TABLE `alert_configurations`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `distribusi`
--
ALTER TABLE `distribusi`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `gudang`
--
ALTER TABLE `gudang`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `harga`
--
ALTER TABLE `harga`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `konfigurasi_harga`
--
ALTER TABLE `konfigurasi_harga`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `lahan`
--
ALTER TABLE `lahan`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `panen`
--
ALTER TABLE `panen`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `petani`
--
ALTER TABLE `petani`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `stok_beras`
--
ALTER TABLE `stok_beras`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alerts`
--
ALTER TABLE `alerts`
  ADD CONSTRAINT `alerts_ditangani_oleh_foreign` FOREIGN KEY (`ditangani_oleh`) REFERENCES `users` (`id`) ON DELETE SET NULL;

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
  ADD CONSTRAINT `users_petani_id_foreign` FOREIGN KEY (`petani_id`) REFERENCES `petani` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
