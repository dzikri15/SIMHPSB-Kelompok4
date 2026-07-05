/**
 * 13-petani-dashboard.spec.ts
 * ------------------------------------------------------------------
 * Menguji resources/views/petani/dashboard.blade.php.
 *
 * File ini berisi DUA skenario yang sengaja dipisah:
 *
 * 1. Regression test untuk BUG NYATA yang ditemukan saat QA: akun seed
 *    `petani@simhpsb.com` (dari DatabaseSeeder) dibuat dengan role
 *    'petani' TAPI tanpa `petani_id` yang valid. PetaniDashboardController
 *    melakukan `abort(404)` bila `$user->petani` kosong. Login-nya
 *    sendiri SUKSES (kredensialnya benar) — yang gagal adalah halaman
 *    dashboard sesudahnya.
 *
 * 2. Uji jalur normal (happy path): daripada menebak-nebak kredensial
 *    petani seed yang sudah punya relasi valid (password aslinya tidak
 *    diketahui karena sudah di-hash), kita membuat akun petani BARU
 *    sendiri lewat Data Petani (yang otomatis membuat User terhubung —
 *    lihat catatan di 04-data-petani.spec.ts) lalu login memakainya.
 *    Ini memberi kita kredensial yang benar-benar valid & diketahui.
 */
import path from 'path';
import { fileURLToPath } from 'url';
import { test as base, expect } from '@playwright/test';
import { test as authTest } from '../fixtures/auth.fixtures';
import { LoginPage } from '../pages/LoginPage';
import { DataPetaniPage } from '../pages/DataPetaniPage';
import { PetaniDashboardPage } from '../pages/PetaniDashboardPage';
import { buildPetaniPayload } from '../fixtures/test-data';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

authTest.describe('[Regression] akun seed petani tanpa petani_id', () => {
  authTest('login sukses tapi dashboard mengembalikan 404 (bug yang sudah diketahui)', async ({ petaniPage }) => {
    const response = await petaniPage.goto('/petani');
    expect(response?.status()).toBe(404);
  });
});

base.describe('Dashboard Petani — jalur normal dengan akun yang benar-benar terhubung', () => {
  base('menampilkan ringkasan data & riwayat panen petani yang baru dibuat', async ({ browser }) => {
    const payload = buildPetaniPayload();

    // --- Langkah 1: sebagai admin, buat petani baru dengan luas lahan > 0 ---
    const adminContext = await browser.newContext({ storageState: path.join(__dirname, '../.auth/admin.json') });
    const adminPage = await adminContext.newPage();
    const dataPetani = new DataPetaniPage(adminPage);
    await dataPetani.goto();
    await dataPetani.openTambahModal();
    await dataPetani.fillModalForm({
      nama: payload.nama,
      email: payload.email,
      password: payload.password,
      passwordConfirmation: payload.password,
      luasLahan: payload.luasLahan, // > 0 supaya otomatis dibuatkan record Lahan
      alamat: payload.alamat,
    });
    await dataPetani.submitModalForm();
    await expect(adminPage).toHaveURL(/\/admin\/petani$/);
    await expect(dataPetani.rowByName(payload.nama)).toBeVisible();
    await adminContext.close();

    // --- Langkah 2: login sebagai petani yang baru saja dibuat ---
    const petaniContext = await browser.newContext();
    const petaniPage = await petaniContext.newPage();
    const login = new LoginPage(petaniPage);
    await login.goto();
    await login.login(payload.email, payload.password);
    await expect(petaniPage).toHaveURL(/\/petani(\/)?$/);

    // --- Langkah 3: verifikasi isi dashboard ---
    const dashboard = new PetaniDashboardPage(petaniPage);
    await dashboard.expectLoadedFor(payload.nama);
    for (const label of ['Total Lahan', 'Total Panen', 'Komoditas']) {
      await expect(dashboard.summaryCards.filter({ hasText: label })).toHaveCount(1);
    }

    await petaniContext.close();
  });

  base('akun petani baru TIDAK bisa mengakses halaman /admin (403)', async ({ browser }) => {
    const payload = buildPetaniPayload();

    const adminContext = await browser.newContext({ storageState: path.join(__dirname, '../.auth/admin.json') });
    const adminPage = await adminContext.newPage();
    const dataPetani = new DataPetaniPage(adminPage);
    await dataPetani.goto();
    await dataPetani.openTambahModal();
    await dataPetani.fillModalForm({
      nama: payload.nama,
      email: payload.email,
      password: payload.password,
      passwordConfirmation: payload.password,
      alamat: payload.alamat,
    });
    await dataPetani.submitModalForm();
    await adminContext.close();

    const petaniContext = await browser.newContext();
    const petaniPage = await petaniContext.newPage();
    const login = new LoginPage(petaniPage);
    await login.goto();
    await login.login(payload.email, payload.password);

    const response = await petaniPage.goto('/admin');
    expect(response?.status()).toBe(403);

    await petaniContext.close();
  });
});
