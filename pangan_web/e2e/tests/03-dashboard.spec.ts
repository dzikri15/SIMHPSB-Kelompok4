/**
 * 03-dashboard.spec.ts
 * ------------------------------------------------------------------
 * Menguji resources/views/admin/dashboard.blade.php, dipakai bersama oleh
 * admin (/admin) dan petugas (/petugas).
 */
import { test, expect } from '../fixtures/auth.fixtures';
import { DashboardPage } from '../pages/DashboardPage';

test.describe('Dashboard Admin', () => {
  test('menampilkan kartu statistik dan grafik', async ({ adminPage }) => {
    const dashboard = new DashboardPage(adminPage);
    await dashboard.gotoAsAdmin();
    await dashboard.expectLoaded();

    await expect(dashboard.chartStokTarget).toBeVisible();
    await expect(dashboard.chartTrenPanen).toBeVisible();
  });

  test('sidebar admin menampilkan seluruh menu (termasuk yang khusus admin)', async ({ adminPage }) => {
    const dashboard = new DashboardPage(adminPage);
    await dashboard.gotoAsAdmin();

    for (const label of ['Data Petani', 'Manajemen Pengguna', 'Manajemen Harga', 'Laporan']) {
      await expect(dashboard.navItem(label)).toBeVisible();
    }
  });

  test('dark mode bisa dinyalakan dan tersimpan di localStorage', async ({ adminPage }) => {
    const dashboard = new DashboardPage(adminPage);
    await dashboard.gotoAsAdmin();

    expect(await dashboard.isDarkModeActive()).toBeFalsy();
    await dashboard.toggleDarkMode();
    expect(await dashboard.isDarkModeActive()).toBeTruthy();

    const stored = await adminPage.evaluate(() => localStorage.getItem('simhpsb_dark_mode'));
    expect(stored).toBe('true');

    // Reload harus tetap gelap karena dibaca ulang dari localStorage
    await adminPage.reload();
    expect(await dashboard.isDarkModeActive()).toBeTruthy();
  });
});

test.describe('Dashboard Petugas', () => {
  test('menampilkan dashboard yang sama, tapi sidebar tidak ada menu khusus admin', async ({ petugasPage }) => {
    const dashboard = new DashboardPage(petugasPage);
    await dashboard.gotoAsPetugas();
    await dashboard.expectLoaded();

    for (const label of ['Manajemen Pengguna', 'Manajemen Harga', 'Laporan']) {
      await expect(dashboard.navItem(label)).toHaveCount(0);
    }
  });
});
