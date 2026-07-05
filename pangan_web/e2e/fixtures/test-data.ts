/**
 * test-data.ts
 * ------------------------------------------------------------------
 * Kredensial & data uji terpusat untuk seluruh test suite SIMHP.
 *
 * Kredensial di bawah ini diambil dari `database/seeders/DatabaseSeeder.php`
 * (bcrypt('password') untuk ketiga akun bawaan). Jangan pernah menaruh
 * password akun produksi di sini — file ini HANYA untuk environment
 * development/testing lokal.
 *
 * CATATAN PENTING (temuan QA):
 * Akun `petani@simhpsb.com` dibuat oleh seeder sebagai User dengan
 * role 'petani', TAPI tidak memiliki `petani_id` yang terhubung ke
 * tabel `petani` manapun. Akibatnya, saat akun ini login dan diarahkan
 * ke /petani, PetaniDashboardController akan memanggil abort(404)
 * karena `$user->petani` bernilai null. Ini BUKAN kesalahan penulisan
 * test — ini perilaku aktual aplikasi saat ini. Lihat
 * `13-petani-dashboard.spec.ts` untuk regression test-nya.
 */

import path from 'path';
import { fileURLToPath } from 'url';

// Proyek ini memakai "type": "module" di package.json (untuk Vite), sehingga
// __dirname bawaan CommonJS tidak tersedia — turunkan manual dari import.meta.url.
const __dirname = path.dirname(fileURLToPath(import.meta.url));

export type Role = 'admin' | 'petugas' | 'petani';

export const USERS: Record<Role, { identifier: string; password: string; name: string }> = {
  admin: {
    identifier: 'admin@simhpsb.com',
    password: 'password',
    name: 'Admin SIMHPSB',
  },
  petugas: {
    identifier: 'petugas@simhpsb.com',
    password: 'password',
    name: 'Petugas SIMHPSB',
  },
  // Akun ini SENGAJA "rusak" (tanpa petani_id terhubung) — lihat catatan di atas.
  petani: {
    identifier: 'petani@simhpsb.com',
    password: 'password',
    name: 'Petani SIMHPSB',
  },
};

/** Path file storageState hasil login, dibuat oleh auth.setup.ts */
export const STORAGE_STATE = {
  admin: '.auth/admin.json',
  petugas: '.auth/petugas.json',
  petani: '.auth/petani.json',
} as const;

/** Helper: bikin string unik supaya data uji tidak bentrok antar test run (unique constraint di DB) */
export function uniqueSuffix(): string {
  return `${Date.now()}-${Math.floor(Math.random() * 10000)}`;
}

/** Data dummy untuk membuat petani baru lewat form */
export function buildPetaniPayload(suffix = uniqueSuffix()) {
  return {
    nama: `Petani Uji ${suffix}`,
    alamat: `Jl. Testing Otomatis No. ${suffix}`,
    telepon: '081200000000',
    email: `petani.${suffix}@example.test`,
    password: 'password123',
    luasLahan: '1500',
  };
}

/** Data dummy untuk membuat pengguna baru lewat form admin */
export function buildPenggunaPayload(suffix = uniqueSuffix()) {
  return {
    nama: `Pengguna Uji ${suffix}`,
    email: `pengguna.${suffix}@example.test`,
    password: 'password123',
  };
}

/** Data dummy tujuan distribusi */
export function buildTujuanNama(suffix = uniqueSuffix()) {
  return `Tujuan Uji ${suffix}`;
}

/** Path dummy file foto bukti untuk upload (dibuat runtime oleh global-setup jika belum ada) */
export const DUMMY_IMAGE_PATH = path.join(__dirname, 'dummy-bukti.png');
