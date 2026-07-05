/**
 * auth.fixtures.ts
 * ------------------------------------------------------------------
 * Extend `test` bawaan Playwright dengan 3 fixture tambahan: adminPage,
 * petugasPage, dan petaniPage. Masing-masing adalah `Page` yang berjalan
 * di browser context terpisah dan SUDAH login (memakai storageState yang
 * dibuat oleh auth.setup.ts).
 *
 * Cara pakai di spec file:
 *
 *   import { test, expect } from '../fixtures/auth.fixtures';
 *
 *   test('admin bisa lihat dashboard', async ({ adminPage }) => {
 *     await adminPage.goto('/admin');
 *     ...
 *   });
 *
 * Fixture `page` bawaan (tanpa login) tetap tersedia seperti biasa —
 * cocok dipakai untuk test halaman login/guest.
 */
import { test as base, expect, type Page } from '@playwright/test';
import path from 'path';
import { fileURLToPath } from 'url';
import { STORAGE_STATE } from './test-data';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

type AuthFixtures = {
  adminPage: Page;
  petugasPage: Page;
  petaniPage: Page;
};

async function createLoggedInPage(browser: any, storageStateFile: string): Promise<{ page: Page; cleanup: () => Promise<void> }> {
  const context = await browser.newContext({
    storageState: path.join(__dirname, storageStateFile),
  });
  const page = await context.newPage();
  return { page, cleanup: () => context.close() };
}

export const test = base.extend<AuthFixtures>({
  adminPage: async ({ browser }, use) => {
    const { page, cleanup } = await createLoggedInPage(browser, STORAGE_STATE.admin);
    await use(page);
    await cleanup();
  },
  petugasPage: async ({ browser }, use) => {
    const { page, cleanup } = await createLoggedInPage(browser, STORAGE_STATE.petugas);
    await use(page);
    await cleanup();
  },
  petaniPage: async ({ browser }, use) => {
    const { page, cleanup } = await createLoggedInPage(browser, STORAGE_STATE.petani);
    await use(page);
    await cleanup();
  },
});

export { expect };
