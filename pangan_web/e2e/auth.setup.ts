/**
 * auth.setup.ts
 * ------------------------------------------------------------------
 * Ini adalah "setup project" Playwright (lihat playwright.config.ts,
 * project bernama 'setup'). File ini dijalankan SEKALI di awal, sebelum
 * project test lain jalan, untuk login sebagai admin, petugas, dan
 * petani lalu menyimpan session-nya (storageState) ke folder .auth/.
 *
 * Kenapa begini? Supaya tiap spec file TIDAK perlu login ulang lewat UI
 * setiap kali (lambat & rawan flaky). Test lain cukup "pinjam" cookie
 * session dari sini lewat fixtures/auth.fixtures.ts.
 *
 * Referensi pola: dokumentasi resmi Playwright - "Authentication" /
 * project dependencies (playwright.dev/docs/auth).
 */
import { test as setup, expect } from '@playwright/test';
import path from 'path';
import { fileURLToPath } from 'url';
import { USERS } from './fixtures/test-data';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const authDir = path.join(__dirname, '.auth');

setup('login sebagai admin', async ({ page }) => {
  await page.goto('/login');
  await page.locator('#identifier').fill(USERS.admin.identifier);
  await page.locator('#password').fill(USERS.admin.password);
  await page.locator('button[type="submit"]').click();

  await page.waitForURL(/\/admin(\/)?$/);
  await expect(page.locator('body')).not.toContainText('These credentials do not match');

  await page.context().storageState({ path: path.join(authDir, 'admin.json') });
});

setup('login sebagai petugas', async ({ page }) => {
  await page.goto('/login');
  await page.locator('#identifier').fill(USERS.petugas.identifier);
  await page.locator('#password').fill(USERS.petugas.password);
  await page.locator('button[type="submit"]').click();

  // Petugas tetap diarahkan ke DashboardController@index lewat prefix /petugas
  await page.waitForURL(/\/petugas(\/)?$/);

  await page.context().storageState({ path: path.join(authDir, 'petugas.json') });
});

setup('login sebagai petani', async ({ page }) => {
  await page.goto('/login');
  await page.locator('#identifier').fill(USERS.petani.identifier);
  await page.locator('#password').fill(USERS.petani.password);
  await page.locator('button[type="submit"]').click();

  // PENTING: akun seed 'petani@simhpsb.com' tidak punya petani_id yang valid,
  // sehingga /petani akan mengembalikan 404 (lihat catatan di test-data.ts).
  // Yang kita simpan di sini HANYA cookie sesi hasil login (proses autentikasinya
  // sendiri sukses) — bukan hasil halaman dashboard. Redirect ke /petani tetap
  // terjadi karena LoginController mengarahkan berdasarkan role, terlepas dari
  // apakah datanya lengkap atau tidak.
  await page.waitForURL(/\/petani(\/)?$/);

  await page.context().storageState({ path: path.join(authDir, 'petani.json') });
});
