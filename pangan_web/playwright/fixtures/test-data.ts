/**
 * test-data.ts
 * ------------------------------------------------------------------
 * Data uji terpusat untuk seluruh test suite SIMHP(SB).
 *
 * PENTING: Kredensial di bawah ini diambil dari
 * database/seeders/DatabaseSeeder.php pada project yang di-upload.
 * Pastikan database sudah di-migrate & di-seed sebelum menjalankan
 * test:
 *
 *   php artisan migrate:fresh --seed
 *
 * Jika kredensial di seeder Anda berbeda (misalnya sudah diubah),
 * sesuaikan nilai-nilai di bawah ini.
 * ------------------------------------------------------------------
 */

import * as path from 'path';
import { fileURLToPath } from 'url';

// __dirname tidak tersedia di ES Module (project ini pakai "type": "module"
// di package.json karena kebutuhan Vite). Ini adalah cara resmi Node.js
// untuk mendapatkan direktori file saat ini di lingkungan ESM:
// https://nodejs.org/api/esm.html#importmetaurl
const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const USERS = {
  admin: {
    identifier: 'admin@simhpsb.com',
    password: 'password',
    role: 'admin',
  },
  petugas: {
    identifier: 'petugas@simhpsb.com',
    password: 'password',
    role: 'petugas',
  },
  petani: {
    identifier: 'petani@simhpsb.com',
    password: 'password',
    role: 'petani',
  },
} as const;

export const INVALID_USER = {
  identifier: 'usernotexist@test.com',
  password: 'anypass123',
};

/**
 * Path ABSOLUT (bukan relatif) ke asset gambar bukti (jpg, ~2.5KB,
 * di bawah limit 2MB/5MB). Menggunakan path.resolve + __dirname agar
 * selalu benar terlepas dari direktori mana `npx playwright test`
 * dijalankan (current working directory tidak memengaruhi ini).
 */
export const BUKTI_IMAGE_PATH = path.resolve(__dirname, '../assets/bukti-test.jpg');

/** Helper untuk data unik agar tiap run test tidak bentrok (unique email/nama). */
export function uniqueSuffix(): string {
  return Date.now().toString().slice(-8);
}

export const BASE_URL = process.env.BASE_URL || 'http://localhost:8000';
