-- SQL dump for SIMHPSB database

DROP DATABASE IF EXISTS `simhpsb_db`;
CREATE DATABASE `simhpsb_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `simhpsb_db`;

-- --------------------------------------------------------
-- Table structure for table `users`
-- --------------------------------------------------------
CREATE TABLE `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `email_verified_at` TIMESTAMP NULL DEFAULT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM('admin','petugas','petani') NOT NULL DEFAULT 'petugas',
  `remember_token` VARCHAR(100) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for table `petani`
-- --------------------------------------------------------
CREATE TABLE `petani` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(255) NOT NULL,
  `alamat` TEXT NOT NULL,
  `no_hp` VARCHAR(50) NULL DEFAULT NULL,
  `email` VARCHAR(255) NULL DEFAULT NULL,
  `tanggal_lahir` DATE NULL DEFAULT NULL,
  `status` ENUM('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for table `lahan`
-- --------------------------------------------------------
CREATE TABLE `lahan` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `petani_id` BIGINT UNSIGNED NOT NULL,
  `nama_lahan` VARCHAR(255) NOT NULL,
  `luas` DECIMAL(10,2) NOT NULL,
  `lokasi` TEXT NOT NULL,
  `jenis_tanah` ENUM('sawah','ladang','kebun') NOT NULL DEFAULT 'sawah',
  `status` ENUM('aktif','tidak_aktif') NOT NULL DEFAULT 'aktif',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_lahan_petani_id` (`petani_id`),
  CONSTRAINT `fk_lahan_petani` FOREIGN KEY (`petani_id`) REFERENCES `petani` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
  INDEX `idx_panen_lahan_id` (`lahan_id`),
  CONSTRAINT `fk_panen_lahan` FOREIGN KEY (`lahan_id`) REFERENCES `lahan` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for table `gudang`
-- --------------------------------------------------------
CREATE TABLE `gudang` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nama_gudang` VARCHAR(255) NOT NULL,
  `lokasi` TEXT NOT NULL,
  `kapasitas` DECIMAL(12,2) NOT NULL,
  `status` ENUM('aktif','tidak_aktif') NOT NULL DEFAULT 'aktif',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for table `stok_beras`
-- --------------------------------------------------------
CREATE TABLE `stok_beras` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `gudang_id` BIGINT UNSIGNED NOT NULL,
  `jumlah_stok` DECIMAL(12,2) NOT NULL,
  `batas_minimum` DECIMAL(12,2) NOT NULL DEFAULT 1000.00,
  `tanggal_update` DATE NOT NULL,
  `catatan` TEXT NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_stok_gudang_id` (`gudang_id`),
  CONSTRAINT `fk_stok_gudang` FOREIGN KEY (`gudang_id`) REFERENCES `gudang` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for table `harga`
-- --------------------------------------------------------
CREATE TABLE `harga` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `komoditas` VARCHAR(255) NOT NULL,
  `harga_per_kg` DECIMAL(12,2) NOT NULL,
  `tanggal_berlaku` DATE NOT NULL,
  `sumber` TEXT NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for table `alert`
-- --------------------------------------------------------
CREATE TABLE `alert` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `message` TEXT NOT NULL,
  `level` ENUM('info','warning','critical') NOT NULL DEFAULT 'warning',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Table structure for table `distribusi`
-- --------------------------------------------------------
CREATE TABLE `distribusi` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `gudang_id` BIGINT UNSIGNED NOT NULL,
  `tujuan` VARCHAR(255) NOT NULL,
  `jumlah_beras` DECIMAL(12,2) NOT NULL,
  `tanggal_distribusi` DATE NOT NULL,
  `catatan` TEXT NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_distribusi_gudang_id` (`gudang_id`),
  CONSTRAINT `fk_distribusi_gudang` FOREIGN KEY (`gudang_id`) REFERENCES `gudang` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Seed data
-- --------------------------------------------------------
INSERT INTO `users` (`name`, `email`, `email_verified_at`, `password`, `role`, `remember_token`, `created_at`, `updated_at`) VALUES
('Admin SIMHPSB', 'admin@simhpsb.com', NULL, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', NULL, NOW(), NOW()),
('Petugas SIMHPSB', 'petugas@simhpsb.com', NULL, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'petugas', NULL, NOW(), NOW()),
('Petani SIMHPSB', 'petani@simhpsb.com', NULL, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'petani', NULL, NOW(), NOW());

INSERT INTO `petani` (`nama`, `alamat`, `no_hp`, `email`, `tanggal_lahir`, `status`, `created_at`, `updated_at`) VALUES
('Budi Santoso', 'Desa Gunung Manik, Majalengka', '081234567890', 'budi.santoso@example.com', '1985-06-12', 'aktif', NOW(), NOW()),
('Siti Aisyah', 'Desa Cisarua, Majalengka', '082345678901', 'siti.aisyah@example.com', '1990-09-25', 'aktif', NOW(), NOW());

INSERT INTO `lahan` (`petani_id`, `nama_lahan`, `luas`, `lokasi`, `jenis_tanah`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Lahan Sawah Utama', 2.50, 'Kawasan Barat Desa Gunung Manik', 'sawah', 'aktif', NOW(), NOW()),
(2, 'Lahan Percontohan', 1.80, 'Kawasan Timur Desa Cisarua', 'ladang', 'aktif', NOW(), NOW());

INSERT INTO `panen` (`lahan_id`, `tanggal_panen`, `jumlah_gabah`, `harga_gabah_per_kg`, `konversi_beras`, `catatan`, `created_at`, `updated_at`) VALUES
(1, '2026-05-01', 1500.00, 8000.00, 900.00, 'Panen sawah musim pertama', NOW(), NOW()),
(2, '2026-05-05', 900.00, 7800.00, 550.00, 'Panen ladang percontohan', NOW(), NOW());

INSERT INTO `gudang` (`nama_gudang`, `lokasi`, `kapasitas`, `status`, `created_at`, `updated_at`) VALUES
('Gudang Utama', 'Pusat Gudang Desa Gunung Manik', 2000.00, 'aktif', NOW(), NOW()),
('Gudang Cadangan', 'Samping Jalan Raya Majalengka', 1500.00, 'aktif', NOW(), NOW());

INSERT INTO `stok_beras` (`gudang_id`, `jumlah_stok`, `batas_minimum`, `tanggal_update`, `catatan`, `created_at`, `updated_at`) VALUES
(1, 850.00, 1000.00, '2026-05-10', 'Stok beras siap distribusi', NOW(), NOW()),
(2, 450.00, 800.00, '2026-05-10', 'Stok beras cadangan', NOW(), NOW());

INSERT INTO `harga` (`komoditas`, `harga_per_kg`, `tanggal_berlaku`, `sumber`, `created_at`, `updated_at`) VALUES
('gabah', 8000.00, '2026-05-01', 'Pasar Lokal', NOW(), NOW()),
('beras', 13500.00, '2026-05-01', 'Supplier Lokal', NOW(), NOW());
