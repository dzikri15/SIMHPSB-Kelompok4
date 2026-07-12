/**
 * auth.ts
 * ------------------------------------------------------------------
 * Custom Playwright fixture yang menyediakan Page yang SUDAH LOGIN
 * untuk masing-masing role (admin, petugas, petani), sesuai referensi
 * resmi Playwright soal "Fixtures" dan "Authentication":
 * https://playwright.dev/docs/test-fixtures
 * https://playwright.dev/docs/auth
 *
 * Kenapa login ulang tiap test (bukan storageState statis)?
 * Karena LoginController men-generate token CSRF baru tiap request
 * GET /login, storageState yang di-generate sekali di awal berisiko
 * kadaluarsa/mismatch session pada test run yang lama. Untuk ukuran
 * suite akademik ini, trade-off kecepatan vs keandalan lebih memilih
 * keandalan (login fresh per test file lewat `test.beforeEach`).
 * ------------------------------------------------------------------
 */
import { test as base, type Page } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { USERS } from './test-data';

type Role = keyof typeof USERS;

type AuthFixtures = {
  adminPage: Page;
  petugasPage: Page;
  petaniPage: Page;
};

async function loginAs(page: Page, role: Role) {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login(USERS[role].identifier, USERS[role].password);
  // Tunggu redirect keluar dari /login (baik ke /admin, /petugas, atau /petani)
  await page.waitForURL((url) => !url.pathname.startsWith('/login'), { timeout: 15000 });
}

export const test = base.extend<AuthFixtures>({
  // eslint-disable-next-line no-empty-pattern
  adminPage: async ({ page }, use) => {
    await loginAs(page, 'admin');
    await use(page);
  },
  // eslint-disable-next-line no-empty-pattern
  petugasPage: async ({ page }, use) => {
    await loginAs(page, 'petugas');
    await use(page);
  },
  // eslint-disable-next-line no-empty-pattern
  petaniPage: async ({ page }, use) => {
    await loginAs(page, 'petani');
    await use(page);
  },
});

export { expect } from '@playwright/test';
