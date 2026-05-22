-- SQL dump for SIMHPSB database (Updated 2026-05-22)
-- Based on latest Laravel migrations

DROP DATABASE IF EXISTS `simhpsb_db`;
CREATE DATABASE `simhpsb_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `simhpsb_db`;

SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- Table structure for table `users`
-- --------------------------------------------------------
CREATE TABLE `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `email_verified_at` TIMESTAMP NULL DEFAULT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` VARCHAR(255) NOT NULL DEFAULT 'admin',
  `petani_id` BIGINT UNSIGNED NULL DEFAULT NULL,
  `remember_token` VARCHAR(100) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  INDEX `idx_users_petani_id` (`petani_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `password_reset_tokens`
-- --------------------------------------------------------
CREATE TABLE `password_reset_tokens` (
  `email` VARCHAR(255) NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `sessions`
-- --------------------------------------------------------
CREATE TABLE `sessions` (
  `id` VARCHAR(255) NOT NULL,
  `user_id` BIGINT UNSIGNED NULL DEFAULT NULL,
  `ip_address` VARCHAR(45) NULL DEFAULT NULL,
  `user_agent` TEXT NULL,
  `payload` LONGTEXT NOT NULL,
  `last_activity` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `sessions_user_id_index` (`user_id`),
  INDEX `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `cache`
-- --------------------------------------------------------
CREATE TABLE `cache` (
  `key` VARCHAR(255) NOT NULL,
  `value` MEDIUMTEXT NOT NULL,
  `expiration` INT NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `cache_locks`
-- --------------------------------------------------------
CREATE TABLE `cache_locks` (
  `key` VARCHAR(255) NOT NULL,
  `owner` VARCHAR(255) NOT NULL,
  `expiration` INT NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `jobs`
-- --------------------------------------------------------
CREATE TABLE `jobs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `queue` VARCHAR(255) NOT NULL,
  `payload` LONGTEXT NOT NULL,
  `attempts` TINYINT UNSIGNED NOT NULL,
  `reserved_at` INT UNSIGNED NULL DEFAULT NULL,
  `available_at` INT UNSIGNED NOT NULL,
  `created_at` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `job_batches`
-- --------------------------------------------------------
CREATE TABLE `job_batches` (
  `id` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `total_jobs` INT NOT NULL,
  `pending_jobs` INT NOT NULL,
  `failed_jobs` INT NOT NULL,
  `failed_job_ids` LONGTEXT NOT NULL,
  `options` MEDIUMTEXT NULL,
  `cancelled_at` INT NULL DEFAULT NULL,
  `created_at` INT NOT NULL,
  `finished_at` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `failed_jobs`
-- --------------------------------------------------------
CREATE TABLE `failed_jobs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` VARCHAR(255) NOT NULL,
  `connection` TEXT NOT NULL,
  `queue` TEXT NOT NULL,
  `payload` LONGTEXT NOT NULL,
  `exception` LONGTEXT NOT NULL,
  `failed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `petani`
-- --------------------------------------------------------
CREATE TABLE `petani` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(255) NOT NULL,
  `nik` VARCHAR(32) NULL DEFAULT NULL,
  `alamat` TEXT NOT NULL,
  `catatan` TEXT NULL DEFAULT NULL,
  `no_hp` VARCHAR(50) NULL DEFAULT NULL,
  `telepon` VARCHAR(50) NULL DEFAULT NULL,
  `email` VARCHAR(255) NULL DEFAULT NULL,
  `tanggal_lahir` DATE NULL DEFAULT NULL,
  `status` ENUM('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `luas_lahan` INT UNSIGNED NULL DEFAULT NULL,
  `komoditas` VARCHAR(255) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `lahan`
-- --------------------------------------------------------
CREATE TABLE `lahan` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `petani_id` BIGINT UNSIGNED NOT NULL,
  `nama_lahan` VARCHAR(255) NOT NULL,
  `luas` DECIMAL(8,2) NOT NULL,
  `lokasi` TEXT NOT NULL,
  `jenis_tanah` ENUM('sawah','ladang','kebun') NOT NULL DEFAULT 'sawah',
  `status` ENUM('aktif','tidak_aktif') NOT NULL DEFAULT 'aktif',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `lahan_petani_id_foreign` (`petani_id`),
  CONSTRAINT `lahan_petani_id_foreign` FOREIGN KEY (`petani_id`) REFERENCES `petani` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `panen`
-- --------------------------------------------------------
CREATE TABLE `panen` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `lahan_id` BIGINT UNSIGNED NOT NULL,
  `tanggal_panen` DATE NOT NULL,
  `jumlah_gabah` DECIMAL(10,2) NOT NULL,
  `harga_gabah_per_kg` DECIMAL(10,2) NULL DEFAULT NULL,
  `konversi_beras` DECIMAL(10,2) NULL DEFAULT NULL,
  `catatan` TEXT NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `panen_lahan_id_foreign` (`lahan_id`),
  CONSTRAINT `panen_lahan_id_foreign` FOREIGN KEY (`lahan_id`) REFERENCES `lahan` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `gudang`
-- --------------------------------------------------------
CREATE TABLE `gudang` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nama_gudang` VARCHAR(255) NOT NULL,
  `lokasi` TEXT NOT NULL,
  `kapasitas` DECIMAL(10,2) NOT NULL,
  `status` ENUM('aktif','maintenance','tidak_aktif') NOT NULL DEFAULT 'aktif',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `stok_beras`
-- --------------------------------------------------------
CREATE TABLE `stok_beras` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `gudang_id` BIGINT UNSIGNED NOT NULL,
  `jumlah_stok` DECIMAL(10,2) NOT NULL,
  `batas_minimum` DECIMAL(10,2) NOT NULL DEFAULT 1000.00,
  `tanggal_update` DATETIME NOT NULL,
  `catatan` TEXT NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `stok_beras_gudang_id_foreign` (`gudang_id`),
  CONSTRAINT `stok_beras_gudang_id_foreign` FOREIGN KEY (`gudang_id`) REFERENCES `gudang` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `harga`
-- --------------------------------------------------------
CREATE TABLE `harga` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `komoditas` VARCHAR(255) NOT NULL,
  `harga_per_kg` DECIMAL(10,2) NOT NULL,
  `tanggal_berlaku` DATE NOT NULL,
  `sumber` TEXT NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `alerts`
-- --------------------------------------------------------
CREATE TABLE `alerts` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `komoditas` VARCHAR(255) NOT NULL,
  `stok_saat_ini` INT NOT NULL,
  `batas_minimum` INT NOT NULL,
  `status` ENUM('aktif','proses','selesai') NOT NULL DEFAULT 'aktif',
  `ditangani_oleh` BIGINT UNSIGNED NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `alerts_ditangani_oleh_foreign` (`ditangani_oleh`),
  CONSTRAINT `alerts_ditangani_oleh_foreign` FOREIGN KEY (`ditangani_oleh`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `distribusi`
-- --------------------------------------------------------
CREATE TABLE `distribusi` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `gudang_id` BIGINT UNSIGNED NOT NULL,
  `jumlah_distribusi` DECIMAL(10,2) NOT NULL,
  `tujuan` VARCHAR(255) NOT NULL,
  `tanggal_distribusi` DATE NOT NULL,
  `catatan` TEXT NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `distribusi_gudang_id_foreign` (`gudang_id`),
  CONSTRAINT `distribusi_gudang_id_foreign` FOREIGN KEY (`gudang_id`) REFERENCES `gudang` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `konfigurasi_harga`
-- --------------------------------------------------------
CREATE TABLE `konfigurasi_harga` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `harga_beli_gabah` DECIMAL(15,2) NOT NULL,
  `ongkos_giling` DECIMAL(15,2) NOT NULL,
  `harga_jual_beras` DECIMAL(15,2) NOT NULL,
  `rasio_konversi` DECIMAL(5,2) NOT NULL,
  `berlaku_mulai` DATE NOT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Foreign Key Constraints
-- --------------------------------------------------------
ALTER TABLE `users` ADD CONSTRAINT `users_petani_id_foreign` FOREIGN KEY (`petani_id`) REFERENCES `petani` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- --------------------------------------------------------
-- Seed data
-- --------------------------------------------------------
INSERT INTO `users` (`name`, `email`, `password`, `role`, `petani_id`, `created_at`, `updated_at`) VALUES
('Admin SIMHPSB', 'admin@simhpsb.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', NULL, NOW(), NOW()),
('Petugas SIMHPSB', 'petugas@simhpsb.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'petugas', NULL, NOW(), NOW()),
('Petani Demo', 'petani@simhpsb.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'petani', NULL, NOW(), NOW());

INSERT INTO `petani` (`nama`, `nik`, `alamat`, `telepon`, `email`, `status`, `luas_lahan`, `komoditas`, `created_at`, `updated_at`) VALUES
('Pak Budi Santoso', '3201010101010001', 'Desa Gunung Manik, Kec. Majalengka', '081234567890', 'budi@example.com', 'aktif', 1, 'beras', NOW(), NOW()),
('Bu Siti Aisyah', '3201010101010002', 'Desa Cisarua, Kec. Majalengka', '082345678901', 'siti@example.com', 'aktif', 2, 'beras', NOW(), NOW());

INSERT INTO `lahan` (`petani_id`, `nama_lahan`, `luas`, `lokasi`, `jenis_tanah`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Lahan Sawah A', 1.20, 'Kawasan Barat Desa Gunung Manik', 'sawah', 'aktif', NOW(), NOW()),
(2, 'Lahan Sawah B', 2.00, 'Kawasan Timur Desa Cisarua', 'sawah', 'aktif', NOW(), NOW());

INSERT INTO `panen` (`lahan_id`, `tanggal_panen`, `jumlah_gabah`, `harga_gabah_per_kg`, `konversi_beras`, `catatan`, `created_at`, `updated_at`) VALUES
(1, '2026-05-10', 1200.00, 3200.00, 720.00, 'Panen musim pertama', NOW(), NOW()),
(2, '2026-05-12', 1500.00, 3200.00, 900.00, 'Panen musim pertama', NOW(), NOW());

INSERT INTO `gudang` (`nama_gudang`, `lokasi`, `kapasitas`, `status`, `created_at`, `updated_at`) VALUES
('Gudang Sentral', 'Pusat Kota Majalengka', 5000.00, 'aktif', NOW(), NOW()),
('Gudang Cabang', 'Samping Jalan Raya', 3000.00, 'aktif', NOW(), NOW());

INSERT INTO `stok_beras` (`gudang_id`, `jumlah_stok`, `batas_minimum`, `tanggal_update`, `catatan`, `created_at`, `updated_at`) VALUES
(1, 1200.00, 1000.00, '2026-05-15 10:30:00', 'Stok beras siap distribusi', NOW(), NOW()),
(2, 400.00, 800.00, '2026-05-15 10:30:00', 'Stok beras cadangan', NOW(), NOW());

INSERT INTO `harga` (`komoditas`, `harga_per_kg`, `tanggal_berlaku`, `sumber`, `created_at`, `updated_at`) VALUES
('Beras', 4500.00, '2026-05-01', 'Pasar Lokal Majalengka', NOW(), NOW()),
('Gabah', 3200.00, '2026-05-01', 'Supplier Petani Lokal', NOW(), NOW());

INSERT INTO `alerts` (`komoditas`, `stok_saat_ini`, `batas_minimum`, `status`, `ditangani_oleh`, `created_at`, `updated_at`) VALUES
('Beras', 400, 500, 'aktif', 2, NOW(), NOW()),
('Gabah', 1200, 800, 'proses', 2, NOW(), NOW());

INSERT INTO `distribusi` (`gudang_id`, `jumlah_distribusi`, `tujuan`, `tanggal_distribusi`, `catatan`, `created_at`, `updated_at`) VALUES
(1, 250.00, 'Pasar Tradisional Majalengka', '2026-05-15', 'Distribusi rutin minggu 1', NOW(), NOW()),
(2, 150.00, 'Koperasi Desa', '2026-05-15', 'Distribusi ke outlet partner', NOW(), NOW());

INSERT INTO `konfigurasi_harga` (`harga_beli_gabah`, `ongkos_giling`, `harga_jual_beras`, `rasio_konversi`, `berlaku_mulai`, `is_active`, `created_at`, `updated_at`) VALUES
(4200.00, 500.00, 12000.00, 0.60, '2026-05-01', TRUE, NOW(), NOW());

SET FOREIGN_KEY_CHECKS = 1;
