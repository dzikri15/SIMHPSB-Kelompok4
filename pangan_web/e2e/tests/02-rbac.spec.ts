/**
 * 02-rbac.spec.ts
 * ------------------------------------------------------------------
 * Menguji middleware RoleMiddleware & pengelompokan route di routes/web.php.
 *
 * Ringkasan aturan yang diverifikasi langsung dari routes/web.php (bukan
 * asumsi dari tampilan sidebar!):
 *
 *   /admin/*   → middleware role:admin,petugas di level group, KECUALI:
 *                - harga, laporan, pengguna, pengaturan → role:admin SAJA
 *   /petugas/* → role:petugas saja
 *   /petani    → role:petani saja
 *
 * TEMUAN QA: sidebar admin (layout/admin.blade.php) menyembunyikan menu
 * "Data Petani" dari role petugas memakai @role('admin') di Blade, TAPI
 * route `admin.petani.*` sendiri TIDAK dibatasi role:admin — masih
 * memakai middleware group terluar (role:admin,petugas). Artinya petugas
 * yang tahu/menebak URL-nya tetap BISA membuka & mengubah Data Petani
 * langsung lewat address bar, walau tidak terlihat di menu. Ini
 * ketidaksesuaian antara UI dan otorisasi backend yang sebaiknya
 * ditinjau ulang oleh tim. Test di bawah men-dokumentasikan perilaku
 * AKTUAL saat ini (bukan menyatakan ini sudah benar).
 */
import { test, expect } from '../fixtures/auth.fixtures';

test.describe('Akses tanpa login (guest)', () => {
  const protectedUrls = ['/admin', '/petugas', '/petani', '/admin/petani', '/admin/harga', '/admin/pengguna'];

  for (const url of protectedUrls) {
    test(`mengakses ${url} tanpa login diarahkan ke /login`, async ({ page }) => {
      await page.goto(url);
      await expect(page).toHaveURL(/\/login$/);
    });
  }
});

test.describe('Admin dapat mengakses seluruh menu /admin', () => {
  const allowedForAdmin = [
    '/admin',
    '/admin/petani',
    '/admin/panen',
    '/admin/stok',
    '/admin/alert',
    '/admin/tujuan-distribusi',
    '/admin/harga',
    '/admin/laporan',
    '/admin/pengguna',
    '/admin/pengaturan',
  ];

  for (const url of allowedForAdmin) {
    test(`admin bisa membuka ${url}`, async ({ adminPage }) => {
      const response = await adminPage.goto(url);
      expect(response?.status(), `${url} harus mengembalikan 200 untuk admin`).toBe(200);
    });
  }

  test('admin TIDAK bisa mengakses /petugas (403) karena role:petugas', async ({ adminPage }) => {
    const response = await adminPage.goto('/petugas');
    expect(response?.status()).toBe(403);
  });

  test('admin TIDAK bisa mengakses /petani (403) karena role:petani', async ({ adminPage }) => {
    const response = await adminPage.goto('/petani');
    expect(response?.status()).toBe(403);
  });
});

test.describe('Petugas: akses sebagian menu /admin (sesuai middleware, bukan sekadar tampilan sidebar)', () => {
  const allowedForPetugas = ['/admin', '/admin/panen', '/admin/stok', '/admin/alert', '/admin/tujuan-distribusi'];
  const forbiddenForPetugas = ['/admin/harga', '/admin/laporan', '/admin/pengguna', '/admin/pengaturan'];

  for (const url of allowedForPetugas) {
    test(`petugas bisa membuka ${url}`, async ({ petugasPage }) => {
      const response = await petugasPage.goto(url);
      expect(response?.status()).toBe(200);
    });
  }

  for (const url of forbiddenForPetugas) {
    test(`petugas mendapat 403 saat membuka ${url} (khusus role:admin)`, async ({ petugasPage }) => {
      const response = await petugasPage.goto(url);
      expect(response?.status()).toBe(403);
    });
  }

  test('[Temuan QA] petugas TETAP bisa membuka /admin/petani via URL langsung walau menu ini disembunyikan di sidebar-nya', async ({ petugasPage }) => {
    const response = await petugasPage.goto('/admin/petani');
    expect(response?.status()).toBe(200);

    // Pastikan menu "Data Petani" memang tidak muncul di sidebar petugas —
    // mengonfirmasi kesenjangan antara UI (disembunyikan) vs backend (diizinkan).
    await petugasPage.goto('/admin');
    const dataPetaniMenu = petugasPage.locator('.sidebar a, #sidebar a').filter({ hasText: 'Data Petani' });
    await expect(dataPetaniMenu).toHaveCount(0);
  });

  test('petugas TIDAK bisa mengakses /petani (403) karena role:petani', async ({ petugasPage }) => {
    const response = await petugasPage.goto('/petani');
    expect(response?.status()).toBe(403);
  });
});

test.describe('Petani: hanya boleh mengakses /petani', () => {
  const forbiddenForPetani = ['/admin', '/admin/petani', '/admin/harga', '/petugas'];

  for (const url of forbiddenForPetani) {
    test(`petani mendapat 403 saat membuka ${url}`, async ({ petaniPage }) => {
      const response = await petaniPage.goto(url);
      expect(response?.status()).toBe(403);
    });
  }
});
