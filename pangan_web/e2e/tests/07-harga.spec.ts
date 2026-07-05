/**
 * 07-harga.spec.ts
 * ------------------------------------------------------------------
 * Menguji admin/harga/index.blade.php + form.blade.php.
 *
 * Aturan bisnis yang diverifikasi dari HargaController:
 *  - Hanya ada SATU konfigurasi yang boleh aktif; mengaktifkan satu akan
 *    menonaktifkan semua yang lain (lihat activate() & store()).
 *  - Konfigurasi yang sedang aktif TIDAK BISA dihapus (tombol Hapus &
 *    Jadikan Aktif tidak ditampilkan sama sekali untuk baris aktif).
 */
import { test, expect } from '../fixtures/auth.fixtures';
import { HargaPage } from '../pages/HargaPage';

test.describe('Manajemen Harga — index', () => {
  test('menampilkan tabel riwayat konfigurasi harga', async ({ adminPage }) => {
    const harga = new HargaPage(adminPage);
    await harga.goto();

    await expect(harga.table).toBeVisible();
    await expect(harga.tambahLink).toBeVisible();
  });
});

test.describe('Manajemen Harga — kalkulator simulasi', () => {
  test('menghitung total nilai gabah & beras secara live', async ({ adminPage }) => {
    const harga = new HargaPage(adminPage);
    await harga.gotoCreate();

    await harga.hargaBeliInput.fill('7600');
    await harga.hargaJualInput.fill('13500');
    await harga.simulasiJumlahInput.fill('2');

    await expect(harga.hasilTotalGabah).toHaveText('Rp 15.200');
    await expect(harga.hasilTotalBeras).toHaveText('Rp 27.000');
  });

  test('input harga diformat otomatis dengan pemisah ribuan', async ({ adminPage }) => {
    const harga = new HargaPage(adminPage);
    await harga.gotoCreate();

    await harga.hargaBeliInput.fill('7600');
    await expect(harga.hargaBeliInput).toHaveValue('7.600');
  });
});

test.describe('Manajemen Harga — tambah, aktifkan, hapus', () => {
  test('menolak submit ketika harga belum diisi (validasi HTML5)', async ({ adminPage }) => {
    const harga = new HargaPage(adminPage);
    await harga.gotoCreate();

    await harga.submitButton.click();
    await expect(adminPage).toHaveURL(/\/admin\/harga\/create$/);
  });

  test('menambah konfigurasi baru sebagai TIDAK aktif', async ({ adminPage }) => {
    const harga = new HargaPage(adminPage);
    await harga.gotoCreate();

    await harga.fillForm({ hargaBeli: '7700', hargaJual: '13800', aktif: false });
    await harga.submit();

    await expect(adminPage).toHaveURL(/\/admin\/harga$/);
    await expect(harga.table).toContainText('7.700');
    await expect(harga.table.locator('tbody tr').filter({ hasText: '7.700' })).toContainText('Tidak Aktif');
  });

  test('menambah konfigurasi baru sebagai AKTIF menonaktifkan yang lain', async ({ adminPage }) => {
    const harga = new HargaPage(adminPage);
    await harga.gotoCreate();

    await harga.fillForm({ hargaBeli: '8000', hargaJual: '14000', aktif: true });
    await harga.submit();

    await expect(adminPage).toHaveURL(/\/admin\/harga$/);
    await expect(adminPage.locator('body')).toContainText(/berhasil/i);

    // Hanya boleh ada SATU baris berstatus "Aktif" di seluruh tabel
    const activeBadges = harga.table.locator('tbody .badge-green', { hasText: 'Aktif' });
    await expect(activeBadges).toHaveCount(1);
  });

  test('konfigurasi yang sedang aktif tidak menampilkan tombol Hapus / Jadikan Aktif', async ({ adminPage }) => {
    const harga = new HargaPage(adminPage);
    await harga.goto();

    const activeRow = harga.table
      .locator('tbody tr')
      .filter({ has: adminPage.locator('.badge-green', { hasText: 'Aktif' }) })
      .first();

    await expect(activeRow.locator('button[title="Hapus"]')).toHaveCount(0);
    await expect(activeRow.locator('button[title="Jadikan Aktif"]')).toHaveCount(0);
  });

  test('mengaktifkan konfigurasi lain lewat tombol "Jadikan Aktif"', async ({ adminPage }) => {
    const harga = new HargaPage(adminPage);
    await harga.gotoCreate();
    await harga.fillForm({ hargaBeli: '7900', hargaJual: '13900', aktif: false });
    await harga.submit();

    const inactiveRow = harga.table.locator('tbody tr').filter({ hasText: '7.900' });
    await harga.activate(inactiveRow);

    await expect(adminPage.locator('body')).toContainText(/berhasil diaktifkan/i);
    await expect(inactiveRow).toContainText('Aktif');
  });

  test('menghapus konfigurasi tidak aktif berhasil menghilangkannya dari tabel', async ({ adminPage }) => {
    const harga = new HargaPage(adminPage);
    await harga.gotoCreate();
    await harga.fillForm({ hargaBeli: '6500', hargaJual: '12500', aktif: false });
    await harga.submit();

    const row = harga.table.locator('tbody tr').filter({ hasText: '6.500' });
    await expect(row).toBeVisible();
    await harga.delete(row, true);

    await expect(harga.table.locator('tbody tr').filter({ hasText: '6.500' })).toHaveCount(0);
  });
});
