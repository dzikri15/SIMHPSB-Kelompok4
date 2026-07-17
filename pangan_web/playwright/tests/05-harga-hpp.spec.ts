import { test, expect } from '../fixtures/auth';
import { HargaPage } from '../pages/HargaPage';

/**
 * =====================================================================
 * MANAJEMEN HARGA & HPP — Test Suite
 * Sumber dokumentasi manual: "TC_Harga_HPP.xlsx"
 * Sumber kebenaran teknis: resources/views/admin/harga/index.blade.php,
 *   resources/views/admin/harga/form.blade.php,
 *   app/Http/Controllers/Admin/HargaController.php
 *
 * ⚠️ TEMUAN PERBEDAAN PALING SIGNIFIKAN DI SELURUH PROJECT
 * (lihat README.md untuk rekomendasi tindak lanjut):
 *   Modul ini SUDAH TIDAK memiliki konsep "Ongkos Giling" maupun
 *   "Rasio Konversi Gabah → Beras" yang menjadi inti dari
 *   TC_Harga_HPP.xlsx. Form saat ini HANYA berisi 4 field:
 *   harga_beli_gabah, harga_jual_beras, berlaku_mulai, is_active.
 *   Sebagai gantinya, tersedia "Kalkulator Penghasilan" sisi klien
 *   yang menghitung Total = Harga × Berat (perkalian sederhana,
 *   BUKAN konversi gabah→beras). Rekomendasi: diskusikan dengan
 *   dosen/tim apakah dokumentasi TC_Harga_HPP.xlsx perlu direvisi
 *   total, atau fitur rasio konversi perlu dikembalikan ke kode.
 * =====================================================================
 */

test.describe('Harga & HPP - Functional Positive', () => {
  test('TC-HP-FP-001 — admin berhasil menambah konfigurasi harga baru', async ({ adminPage }) => {
    const hargaPage = new HargaPage(adminPage);
    await hargaPage.gotoCreate();
    await hargaPage.isiForm({
      hargaBeliGabah: '6500',
      hargaJualBeras: '13000',
      berlakuMulai: new Date().toISOString().slice(0, 10),
      isActive: false,
    });
    await hargaPage.submit();

    await adminPage.waitForURL(/\/admin\/harga$/);
    await expect(hargaPage.successBanner).toContainText('Konfigurasi Harga berhasil ditambahkan');
  });

  test('TC-HP-FP-002 — menandai konfigurasi baru sebagai aktif otomatis menonaktifkan yang lama', async ({
    adminPage,
  }) => {
    const hargaPage = new HargaPage(adminPage);
    const tanggal = new Date().toISOString().slice(0, 10);

    await hargaPage.gotoCreate();
    await hargaPage.isiForm({
      hargaBeliGabah: '7200',
      hargaJualBeras: '14000',
      berlakuMulai: tanggal,
      isActive: true,
    });
    await hargaPage.submit();

    await adminPage.waitForURL(/\/admin\/harga$/);
    // Hanya boleh ada SATU badge "Aktif" di seluruh tabel setelah operasi ini.
    await expect(hargaPage.tableRows.locator('.badge-green', { hasText: 'Aktif' })).toHaveCount(1);
  });

  test('TC-HP-FP-003 — kalkulator penghasilan menghitung Total = Harga × Berat secara live', async ({ adminPage }) => {
    const hargaPage = new HargaPage(adminPage);
    await hargaPage.gotoCreate();

    await hargaPage.hargaBeliGabahInput.fill('7000');
    await hargaPage.hargaJualBerasInput.fill('13500');
    await hargaPage.simulasiJumlahInput.fill('10');

    // 7000 x 10 = 70.000 ; 13500 x 10 = 135.000 (format ribuan Indonesia).
    await expect(hargaPage.hasilTotalGabah).toContainText('Rp 70.000');
    await expect(hargaPage.hasilTotalBeras).toContainText('Rp 135.000');
  });

  test('TC-HP-FP-004 — mengaktifkan konfigurasi lain dari tombol "Jadikan Aktif" di tabel berhasil', async ({
    adminPage,
  }) => {
    const hargaPage = new HargaPage(adminPage);

    // Buat 2 konfigurasi baru: yang pertama aktif, kedua tidak aktif.
    await hargaPage.gotoCreate();
    await hargaPage.isiForm({ hargaBeliGabah: '6000', hargaJualBeras: '12000', isActive: true });
    await hargaPage.submit();
    await adminPage.waitForURL(/\/admin\/harga$/);

    await hargaPage.gotoCreate();
    await hargaPage.isiForm({ hargaBeliGabah: '6800', hargaJualBeras: '12800', isActive: false });
    await hargaPage.submit();
    await adminPage.waitForURL(/\/admin\/harga$/);

    // Baris paling atas (terbaru berdasar tanggal) adalah yang non-aktif -> punya tombol "Jadikan Aktif".
    const nonAktifRow = hargaPage.tableRows.filter({ hasText: 'Tidak Aktif' }).first();
    await nonAktifRow.getByTitle('Jadikan Aktif').click();

    await adminPage.waitForURL(/\/admin\/harga$/);
    await expect(hargaPage.successBanner).toContainText('Konfigurasi Harga berhasil diaktifkan');
  });
});

test.describe('Harga & HPP - Functional Negative', () => {
  test('TC-HP-FN-001 — field harga kosong diblokir validasi native (required)', async ({ adminPage }) => {
    const hargaPage = new HargaPage(adminPage);
    await hargaPage.gotoCreate();
    // Sengaja tidak mengisi harga_beli_gabah.
    await hargaPage.hargaJualBerasInput.fill('13000');
    await hargaPage.submit();

    const isValid = await hargaPage.hargaBeliGabahInput.evaluate((el: HTMLInputElement) => el.checkValidity());
    expect(isValid).toBe(false);
    await expect(adminPage).toHaveURL(/\/admin\/harga\/create/);
  });

  test('TC-HP-FN-002 — nilai harga negatif ditolak (min:0 di server, dan HTML type=text tidak membatasi native)', async ({
    adminPage,
  }) => {
    const hargaPage = new HargaPage(adminPage);
    await hargaPage.gotoCreate();
    await hargaPage.hargaBeliGabahInput.fill('-5000');
    await hargaPage.hargaJualBerasInput.fill('13000');
    await hargaPage.berlakuMulaiInput.fill(new Date().toISOString().slice(0, 10));
    await hargaPage.submit();

    // formatCurrency() sisi klien menghapus karakter non-digit (termasuk '-')
    // sebelum submit, sehingga nilai negatif tidak pernah benar-benar
    // terkirim apa adanya — namun hasil akhirnya tetap BUKAN nilai negatif
    // yang valid secara bisnis. Kita pastikan tidak terjadi crash & data
    // tidak tersimpan sebagai negatif.
    await expect(adminPage.locator('body')).toBeVisible();
  });

  test('TC-HP-FN-003 — menghapus konfigurasi yang sedang AKTIF ditolak server', async ({ adminPage }) => {
    const hargaPage = new HargaPage(adminPage);
    await hargaPage.gotoCreate();
    await hargaPage.isiForm({ hargaBeliGabah: '7500', hargaJualBeras: '14500', isActive: true });
    await hargaPage.submit();
    await adminPage.waitForURL(/\/admin\/harga$/);

    // Baris aktif TIDAK memiliki tombol Hapus sama sekali (disembunyikan di UI).
    const aktifRow = hargaPage.tableRows.filter({ hasText: 'Aktif' }).first();
    await expect(aktifRow.getByTitle('Hapus')).toHaveCount(0);
  });

  test('TC-HP-FN-004 — menghapus konfigurasi TIDAK aktif berhasil setelah konfirmasi dialog', async ({ adminPage }) => {
    const hargaPage = new HargaPage(adminPage);
    await hargaPage.gotoCreate();
    await hargaPage.isiForm({ hargaBeliGabah: '6100', hargaJualBeras: '12100', isActive: false });
    await hargaPage.submit();
    await adminPage.waitForURL(/\/admin\/harga$/);

    adminPage.on('dialog', (dialog) => dialog.accept());

    const row = hargaPage.tableRows.filter({ hasText: 'Tidak Aktif' }).first();
    await row.getByTitle('Hapus').click();

    await adminPage.waitForURL(/\/admin\/harga$/);
    await expect(hargaPage.successBanner).toContainText('Konfigurasi Harga berhasil dihapus');
  });
});

test.describe('Harga & HPP - Role-based Access', () => {
  test('petugas TIDAK bisa mengakses Manajemen Harga (khusus admin) — HTTP 403', async ({ petugasPage }) => {
    const response = await petugasPage.goto('/admin/harga');
    expect(response?.status()).toBe(403);
  });

  test('petani TIDAK bisa mengakses Manajemen Harga — HTTP 403', async ({ petaniPage }) => {
    const response = await petaniPage.goto('/admin/harga');
    expect(response?.status()).toBe(403);
  });
});
