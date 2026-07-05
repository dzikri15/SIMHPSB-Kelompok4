/**
 * 05-panen.spec.ts
 * ------------------------------------------------------------------
 * Menguji admin/panen/index.blade.php: dropdown petani kustom (search +
 * pilih), pengisian form, upload foto bukti wajib, dan hapus riwayat
 * (native confirm dialog).
 */
import path from 'path';
import { test, expect } from '../fixtures/auth.fixtures';
import { PanenPage } from '../pages/PanenPage';
import { DUMMY_IMAGE_PATH } from '../fixtures/test-data';

const PETANI_SEED = 'Pak Budi'; // dari database/seeders — lihat simhpsb_db.sql tabel `petani`

test.describe('Pencatatan Panen — dropdown petani kustom', () => {
  test('dropdown terbuka saat diklik dan bisa dicari', async ({ adminPage }) => {
    const panen = new PanenPage(adminPage);
    await panen.goto();

    await panen.petaniDisplay.click();
    await expect(panen.petaniPanel).toBeVisible();

    await panen.petaniSearchInput.fill('zzz_tidak_ada');
    await expect(adminPage.locator('#petaniList .petani-opt:visible')).toHaveCount(0);

    await panen.petaniSearchInput.fill('budi');
    await expect(adminPage.locator('#petaniList .petani-opt:visible')).toContainText('Pak Budi');
  });

  test('memilih petani mengisi input hidden & menutup panel', async ({ adminPage }) => {
    const panen = new PanenPage(adminPage);
    await panen.goto();

    await panen.choosePetaniByName(PETANI_SEED);
    await panen.expectPetaniSelected(PETANI_SEED);
    await expect(panen.petaniPanel).toBeHidden();
  });
});

test.describe('Pencatatan Panen — submit form', () => {
  test('berhasil mencatat panen baru dengan foto bukti', async ({ adminPage }) => {
    const panen = new PanenPage(adminPage);
    await panen.goto();

    await panen.choosePetaniByName(PETANI_SEED);
    await panen.fillForm({
      musim: 'Kemarau',
      jumlahGabah: '3500',
      catatan: 'Dibuat otomatis oleh Playwright',
      fotoPath: DUMMY_IMAGE_PATH,
    });
    await panen.submit();

    await expect(adminPage).toHaveURL(/\/admin\/panen$/);
    await expect(panen.rowByPetaniName(PETANI_SEED).first()).toBeVisible();
  });

  test('menampilkan pesan error saat petani belum dipilih', async ({ adminPage }) => {
    const panen = new PanenPage(adminPage);
    await panen.goto();

    await panen.musimSelect.selectOption('Kemarau');
    await panen.jumlahGabahInput.fill('1000');
    await panen.fotoInput.setInputFiles(DUMMY_IMAGE_PATH);
    await panen.submit();

    await expect(adminPage.locator('.alert-banner.danger')).toBeVisible();
    await expect(adminPage.locator('.alert-banner.danger')).toContainText(/petani/i);
  });

  test('menolak submit tanpa foto bukti (atribut required)', async ({ adminPage }) => {
    const panen = new PanenPage(adminPage);
    await panen.goto();

    await panen.choosePetaniByName(PETANI_SEED);
    await panen.musimSelect.selectOption('Hujan');
    await panen.jumlahGabahInput.fill('1200');
    await panen.submit();

    // Validasi HTML5 `required` pada input file menahan submit di client
    await expect(adminPage).toHaveURL(/\/admin\/panen$/);
    const isValid = await panen.fotoInput.evaluate((el: HTMLInputElement) => el.validity.valid);
    expect(isValid).toBeFalsy();
  });

  test('input jumlah gabah tidak menerima angka negatif (min=1)', async ({ adminPage }) => {
    const panen = new PanenPage(adminPage);
    await panen.goto();

    await panen.jumlahGabahInput.fill('-5');
    const isValid = await panen.jumlahGabahInput.evaluate((el: HTMLInputElement) => el.validity.valid);
    expect(isValid).toBeFalsy();
  });
});

test.describe('Pencatatan Panen — hapus riwayat', () => {
  test('membatalkan konfirmasi hapus tidak menghapus data', async ({ adminPage }) => {
    const panen = new PanenPage(adminPage);
    await panen.goto();
    await panen.choosePetaniByName(PETANI_SEED);
    await panen.fillForm({ musim: 'Kemarau', jumlahGabah: '999', fotoPath: DUMMY_IMAGE_PATH });
    await panen.submit();

    const rowsBefore = await panen.riwayatTable.locator('tr.panen-row').count();
    await panen.deleteRow(PETANI_SEED, false);
    await expect(panen.riwayatTable.locator('tr.panen-row')).toHaveCount(rowsBefore);
  });

  test('mengonfirmasi hapus menghilangkan baris dari riwayat', async ({ adminPage }) => {
    const panen = new PanenPage(adminPage);
    await panen.goto();
    await panen.choosePetaniByName(PETANI_SEED);
    await panen.fillForm({ musim: 'Kemarau', jumlahGabah: '888', fotoPath: DUMMY_IMAGE_PATH });
    await panen.submit();

    const rowsBefore = await panen.riwayatTable.locator('tr.panen-row').count();
    await panen.deleteRow(PETANI_SEED, true);
    await expect(panen.riwayatTable.locator('tr.panen-row')).toHaveCount(rowsBefore - 1);
  });
});
