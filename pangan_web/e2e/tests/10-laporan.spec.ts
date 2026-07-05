/**
 * 10-laporan.spec.ts
 * ------------------------------------------------------------------
 * Menguji admin/laporan/index.blade.php. Halaman ini HANYA bisa diakses
 * role admin (lihat 02-rbac.spec.ts).
 */
import { test, expect } from '../fixtures/auth.fixtures';
import { LaporanPage } from '../pages/LaporanPage';

test.describe('Laporan — tampilan default', () => {
  test('default menampilkan Laporan Stok dengan filter komoditas', async ({ adminPage }) => {
    const laporan = new LaporanPage(adminPage);
    await laporan.goto();

    await expect(laporan.jenisSelect).toHaveValue('stok');
    await expect(laporan.komoditasWrapper).toBeVisible();
    await expect(laporan.petaniWrapper).toBeHidden();
    await expect(laporan.chart).toBeVisible();
  });

  test('link export PDF & Excel tersedia', async ({ adminPage }) => {
    const laporan = new LaporanPage(adminPage);
    await laporan.goto();

    await expect(laporan.exportPdfLink).toBeVisible();
    await expect(laporan.exportExcelLink).toBeVisible();
  });
});

test.describe('Laporan — beralih jenis laporan', () => {
  test('memilih "Laporan Panen" menukar filter komoditas jadi filter petani', async ({ adminPage }) => {
    const laporan = new LaporanPage(adminPage);
    await laporan.goto();

    await laporan.selectJenis('panen');

    await expect(adminPage).toHaveURL(/[?&]jenis=panen/);
    await expect(laporan.jenisSelect).toHaveValue('panen');
    await expect(laporan.petaniWrapper).toBeVisible();
    await expect(laporan.komoditasWrapper).toBeHidden();
  });

  test('kembali ke "Laporan Stok" menampilkan lagi filter komoditas', async ({ adminPage }) => {
    const laporan = new LaporanPage(adminPage);
    await laporan.goto();
    await laporan.selectJenis('panen');
    await laporan.selectJenis('stok');

    await expect(laporan.komoditasWrapper).toBeVisible();
    await expect(laporan.petaniWrapper).toBeHidden();
  });
});

test.describe('Laporan — filter tanggal & komoditas', () => {
  test('mengubah komoditas langsung memuat ulang laporan (auto-submit)', async ({ adminPage }) => {
    const laporan = new LaporanPage(adminPage);
    await laporan.goto();

    const optionCount = await laporan.komoditasSelect.locator('option').count();
    test.skip(optionCount < 2, 'Tidak ada opsi komoditas selain "Semua Komoditas" untuk diuji.');

    await laporan.selectKomoditas(await laporan.komoditasSelect.locator('option').nth(1).getAttribute('value') ?? '');
    await expect(adminPage).toHaveURL(/[?&]komoditas=/);
  });

  test('mengatur rentang tanggal dan menekan "Tampilkan"', async ({ adminPage }) => {
    const laporan = new LaporanPage(adminPage);
    await laporan.goto();

    await laporan.setRange('2026-01-01', '2026-01-31');
    await adminPage.getByRole('button', { name: /Tampilkan/i }).click();

    await expect(adminPage).toHaveURL(/dari=2026-01-01/);
    await expect(adminPage).toHaveURL(/sampai=2026-01-31/);
  });
});
