/**
 * 06-stok.spec.ts
 * ------------------------------------------------------------------
 * Menguji admin/stok/index.blade.php — bagian paling kompleks: modal
 * transaksi dengan banyak logika kondisional (lihat komentar di
 * pages/StokPage.ts untuk ringkasannya).
 */
import { test, expect } from '../fixtures/auth.fixtures';
import { StokPage } from '../pages/StokPage';
import { DUMMY_IMAGE_PATH, uniqueSuffix } from '../fixtures/test-data';

test.describe('Stok Gudang — index', () => {
  test('menampilkan kartu ringkasan dan tabel transaksi', async ({ adminPage }) => {
    const stok = new StokPage(adminPage);
    await stok.goto();

    await expect(stok.statBeras).toBeVisible();
    await expect(stok.statGabah).toBeVisible();
    await expect(stok.table).toBeVisible();
  });

  test('pencarian & filter client-side menyaring baris', async ({ adminPage }) => {
    const stok = new StokPage(adminPage);
    await stok.goto();

    await stok.searchInput.fill('zzz_kata_kunci_tidak_ada_zzz');
    await expect(stok.table.locator('tbody tr:visible')).toHaveCount(0);

    await stok.searchInput.fill('');
    await stok.filterJenis.selectOption('masuk');
    const rows = stok.table.locator('tbody tr:visible');
    const count = await rows.count();
    for (let i = 0; i < count; i++) {
      await expect(rows.nth(i)).toContainText(/masuk/i);
    }
  });
});

test.describe('Stok Gudang — logika kondisional modal transaksi', () => {
  test('memilih komoditas "Gabah" menyembunyikan opsi "Masuk" dan otomatis pindah ke "Keluar"', async ({ adminPage }) => {
    const stok = new StokPage(adminPage);
    await stok.goto();
    await stok.openTambahModal();

    await stok.selectJenis('masuk');
    await stok.selectKomoditas('Gabah');

    await expect(stok.jenisSelect).toHaveValue('keluar');
    const masukOptionDisplay = await adminPage
      .locator('#jenisTransaksi option[value="masuk"]')
      .evaluate((el) => (el as HTMLElement).style.display);
    expect(masukOptionDisplay).toBe('none');
  });

  test('tujuan distribusi hanya wajib & tampil untuk kombinasi Keluar + Beras', async ({ adminPage }) => {
    const stok = new StokPage(adminPage);
    await stok.goto();
    await stok.openTambahModal();

    await stok.selectKomoditas('Beras');
    await stok.selectJenis('keluar');
    await expect(stok.tujuanGroup).toBeVisible();
    await expect(stok.tujuanSelect).toHaveAttribute('required', /.*/);

    await stok.selectJenis('masuk');
    await expect(stok.tujuanGroup).toBeHidden();
  });

  test('field foto bukti tampil & wajib begitu jenis dipilih (masuk maupun keluar)', async ({ adminPage }) => {
    const stok = new StokPage(adminPage);
    await stok.goto();
    await stok.openTambahModal();

    await expect(stok.fotoBuktiGroup).toBeHidden();
    await stok.selectKomoditas('Beras');
    await stok.selectJenis('keluar');
    await expect(stok.fotoBuktiGroup).toBeVisible();
    await expect(stok.fotoBuktiInput).toHaveAttribute('required', /.*/);
  });

  test('jenis Masuk + komoditas Gabah menukar field keterangan jadi dropdown pilih petani', async ({ adminPage }) => {
    const stok = new StokPage(adminPage);
    await stok.goto();
    await stok.openTambahModal();

    // Urutan: pilih Gabah dulu, lalu jenis akan otomatis "keluar" (lihat test di atas).
    // Untuk mendapatkan kombinasi masuk+Gabah, pilih jenis SETELAH komoditas, seperti pengguna asli.
    await stok.selectKomoditas('Gabah');
    // 'masuk' disembunyikan lewat CSS (bukan disabled), sehingga tetap bisa dipilih
    // secara terprogram — ini juga men-simulasikan skenario pengguna yang mem-bypass
    // client-side restriction (mis. lewat devtools), untuk menguji jaring pengaman di server.
    await stok.jenisSelect.selectOption('masuk');

    await expect(stok.keteranganPetaniSelect).toBeVisible();
    await expect(stok.keteranganText).toBeHidden();
  });
});

test.describe('Stok Gudang — submit transaksi', () => {
  test('berhasil mencatat transaksi Keluar Beras dengan tujuan & foto bukti', async ({ adminPage }) => {
    const stok = new StokPage(adminPage);
    const marker = `AutoTest-${uniqueSuffix()}`;
    await stok.goto();
    await stok.openTambahModal();

    await stok.selectKomoditas('Beras');
    await stok.selectJenis('keluar');
    await stok.jumlahInput.fill('50');
    await stok.tujuanSelect.selectOption('Toko Rudi');
    await stok.keteranganText.fill(marker);
    await stok.fotoBuktiInput.setInputFiles(DUMMY_IMAGE_PATH);
    await stok.submitTransaksiButton.click();

    await expect(adminPage).toHaveURL(/\/admin\/stok$/);
    await expect(stok.table).toContainText(marker);
  });

  test('server menolak "Gabah Masuk" walau dipilih paksa lewat dropdown (jaring pengaman server-side)', async ({ adminPage }) => {
    const stok = new StokPage(adminPage);
    await stok.goto();
    await stok.openTambahModal();

    await stok.selectKomoditas('Gabah');
    await stok.jenisSelect.selectOption('masuk'); // bypass batasan client-side
    await stok.jumlahInput.fill('10');
    await stok.keteranganPetaniSelect.selectOption({ index: 1 });
    await stok.fotoBuktiInput.setInputFiles(DUMMY_IMAGE_PATH);
    await stok.submitTransaksiButton.click();

    await expect(adminPage.locator('.alert-banner.danger')).toContainText(/Pencatatan Panen/i);
  });

  test('membatalkan (toggle) transaksi aktif mengubah status menjadi Dibatalkan', async ({ adminPage }) => {
    const stok = new StokPage(adminPage);
    const marker = `AutoTest-${uniqueSuffix()}`;
    await stok.goto();
    await stok.openTambahModal();
    await stok.selectKomoditas('Beras');
    await stok.selectJenis('keluar');
    await stok.jumlahInput.fill('25');
    await stok.tujuanSelect.selectOption('Toko Rudi');
    await stok.keteranganText.fill(marker);
    await stok.fotoBuktiInput.setInputFiles(DUMMY_IMAGE_PATH);
    await stok.submitTransaksiButton.click();
    await expect(adminPage).toHaveURL(/\/admin\/stok$/);

    const row = stok.table.locator('tbody tr').filter({ hasText: marker });
    await expect(row).toContainText('Aktif');

    await row.locator('button[title="Batalkan transaksi"]').click();
    await expect(row).toContainText('Dibatalkan');
  });
});
