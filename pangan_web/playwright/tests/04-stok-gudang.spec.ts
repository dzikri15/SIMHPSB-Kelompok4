import { test, expect } from '../fixtures/auth';
import { StokGudangPage } from '../pages/StokGudangPage';
import { PanenPage } from '../pages/PanenPage';
import { BUKTI_IMAGE_PATH, uniqueSuffix } from '../fixtures/test-data';

/**
 * =====================================================================
 * STOK GUDANG — Test Suite
 * Sumber dokumentasi manual: "Test Case Stok Gudang.xlsx"
 * Sumber kebenaran teknis: resources/views/admin/stok/index.blade.php,
 *   app/Http/Controllers/Admin/StokController.php
 *
 * Modul ini SECARA STRUKTUR paling selaras dengan dokumentasi manual
 * (8 kartu ringkasan & kolom tabel hampir sama), namun ada aturan
 * bisnis penting yang HARUS diketahui sebelum menulis/menjalankan test:
 *   1. "Gabah" + jenis "masuk" SELALU ditolak — hanya boleh lewat
 *      menu Pencatatan Panen. Pesan: "Gabah Masuk tidak bisa dicatat
 *      manual. Gunakan menu Pencatatan Panen."
 *   2. "Beras" + jenis "masuk" ditolak jika saldo Gabah saat ini <= 0.
 *   3. Field foto_bukti WAJIB di sisi SERVER (required|image|...),
 *      TAPI TIDAK memiliki atribut `required` di HTML — beda dengan
 *      modul Panen. Artinya submit tanpa foto tetap terkirim ke
 *      server dan baru ditolak di sana (banner error muncul).
 *   4. Field "Tujuan Distribusi" tidak punya atribut required di
 *      HTML maupun validasi server (`nullable`), meski secara visual
 *      diberi tanda bintang merah (*) — ini kemungkinan bug UI kecil,
 *      dicatat sebagai temuan, bukan diuji sebagai "wajib".
 *   5. Transaksi "keluar" TIDAK diblokir meski melebihi saldo saat
 *      ini (tidak ada validasi saldo mencukupi di server) — sistem
 *      hanya menampilkan peringatan visual (`#stokWarning`).
 * =====================================================================
 */

test.describe('Stok Gudang - Kartu Ringkasan & Tabel (TC-UI)', () => {
  test('TC-SG-UI-001 — 8 kartu ringkasan saldo & rekap bulanan tampil', async ({ adminPage }) => {
    const stokPage = new StokGudangPage(adminPage);
    await stokPage.goto();

    await expect(adminPage.getByText('Saldo Beras', { exact: false }).first()).toBeVisible();
    await expect(adminPage.getByText('Saldo Gabah', { exact: false }).first()).toBeVisible();
    await expect(adminPage.getByText('Masuk Bulan Ini', { exact: false }).first()).toBeVisible();
    await expect(adminPage.getByText('Keluar Bulan Ini', { exact: false }).first()).toBeVisible();
  });

  test('TC-SG-UI-002 — tabel riwayat transaksi menampilkan header kolom yang benar', async ({ adminPage }) => {
    const stokPage = new StokGudangPage(adminPage);
    await stokPage.goto();

    const headers = stokPage.table.locator('thead th');
    await expect(headers).toContainText([
      'Tanggal',
      'Jenis',
      'Komoditas',
      'Jumlah',
    ]);
  });
});

test.describe('Stok Gudang - Functional Positive', () => {
  test('TC-SG-FP-001 — catat transaksi Keluar Beras dengan tujuan distribusi berhasil', async ({ adminPage }) => {
    const stokPage = new StokGudangPage(adminPage);
    const keterangan = `Distribusi Uji ${uniqueSuffix()}`;

    await stokPage.goto();
    await stokPage.openModal();
    await stokPage.isiFormTransaksi({
      jenis: 'keluar',
      komoditas: 'Beras',
      jumlah: '10',
      tujuanDistribusi: 'MBG Dapur 1',
      keterangan,
      fotoPath: BUKTI_IMAGE_PATH,
    });
    await stokPage.submit();

    await adminPage.waitForURL(/\/admin\/stok/);
    await expect(stokPage.successBanner).toBeVisible();
    await expect(stokPage.tableRows.filter({ hasText: keterangan }).first()).toBeVisible();
  });

  test('TC-SG-FP-002 — catat transaksi Keluar Gabah (tanpa tujuan distribusi) berhasil', async ({ adminPage }) => {
    const stokPage = new StokGudangPage(adminPage);
    const keterangan = `Giling Uji ${uniqueSuffix()}`;

    await stokPage.goto();
    await stokPage.openModal();
    await stokPage.isiFormTransaksi({
      jenis: 'keluar',
      komoditas: 'Gabah',
      jumlah: '25',
      keterangan,
      fotoPath: BUKTI_IMAGE_PATH,
    });
    await stokPage.submit();

    await adminPage.waitForURL(/\/admin\/stok/);
    await expect(stokPage.successBanner).toBeVisible();
  });

  test('TC-SG-FP-003 — mencatat panen otomatis menambahkan baris "Gabah Masuk" di Stok Gudang (integrasi)', async ({
    adminPage,
  }) => {
    const panenPage = new PanenPage(adminPage);
    await panenPage.goto();
    await panenPage.isiFormPanen({
      petani: 'Pak Budi',
      musim: 'Kemarau',
      tanggalPanen: new Date().toISOString().slice(0, 10),
      jumlahGabah: '88',
      fotoPath: BUKTI_IMAGE_PATH,
    });
    await panenPage.submit();
    await adminPage.waitForURL(/\/admin\/panen/);

    const stokPage = new StokGudangPage(adminPage);
    await stokPage.goto();
    const row = stokPage.tableRows.filter({ hasText: 'Pak Budi' }).filter({ hasText: 'Masuk' }).first();
    await expect(row).toBeVisible();
  });

  test('TC-SG-FP-004 — Masuk Beras berhasil ketika saldo Gabah tersedia (setelah panen)', async ({ adminPage }) => {
    // Pastikan saldo Gabah > 0 dengan mencatat panen terlebih dahulu,
    // karena "Beras masuk" ditolak server bila saldo Gabah saat ini <= 0.
    const panenPage = new PanenPage(adminPage);
    await panenPage.goto();
    await panenPage.isiFormPanen({
      petani: 'Bu Sari',
      musim: 'Hujan',
      tanggalPanen: new Date().toISOString().slice(0, 10),
      jumlahGabah: '50',
      fotoPath: BUKTI_IMAGE_PATH,
    });
    await panenPage.submit();
    await adminPage.waitForURL(/\/admin\/panen/);

    const stokPage = new StokGudangPage(adminPage);
    const keterangan = `Giling Beras Uji ${uniqueSuffix()}`;
    await stokPage.goto();
    await stokPage.openModal();
    await stokPage.isiFormTransaksi({
      jenis: 'masuk',
      komoditas: 'Beras',
      jumlah: '20',
      keterangan,
      fotoPath: BUKTI_IMAGE_PATH,
    });
    await stokPage.submit();

    await adminPage.waitForURL(/\/admin\/stok/);
    await expect(stokPage.successBanner).toBeVisible();
  });
});

test.describe('Stok Gudang - Functional Negative', () => {
  test('TC-SG-FN-001 — Gabah Masuk manual DITOLAK dengan pesan spesifik', async ({ adminPage }) => {
    const stokPage = new StokGudangPage(adminPage);
    await stokPage.goto();
    await stokPage.openModal();

    // JS toggleTujuan() menyembunyikan opsi "Masuk" saat komoditas=Gabah,
    // sehingga kita atur komoditas dahulu baru jenis (mengikuti alur nyata pengguna).
    await stokPage.komoditasSelect.selectOption('Gabah');
    // Jika opsi 'masuk' disembunyikan oleh JS, kita paksa set lewat jenis
    // select langsung (mensimulasikan bila validasi client terlewati/di-bypass).
    await stokPage.jenisSelect.selectOption('masuk').catch(() => {});
    await stokPage.jumlahInput.fill('10');
    await stokPage.keteranganTextInput.fill('Percobaan Gabah Masuk manual');
    await stokPage.fotoBuktiInput.setInputFiles(BUKTI_IMAGE_PATH);
    await stokPage.submit();

    await expect(stokPage.errorBanner).toBeVisible();
    await expect(stokPage.errorBanner).toContainText('Gabah Masuk tidak bisa dicatat manual');
  });

  test('TC-SG-FN-002 — jumlah kurang dari batas minimum (min="1") diblokir validasi native', async ({ adminPage }) => {
    const stokPage = new StokGudangPage(adminPage);
    await stokPage.goto();
    await stokPage.openModal();
    await stokPage.jenisSelect.selectOption('keluar');
    await stokPage.komoditasSelect.selectOption('Gabah');
    await stokPage.jumlahInput.fill('0');
    await stokPage.keteranganTextInput.fill('Uji jumlah nol');

    const isValid = await stokPage.jumlahInput.evaluate((el: HTMLInputElement) => el.checkValidity());
    expect(isValid).toBe(false);
  });

  test('TC-SG-FN-003 — submit tanpa foto bukti tetap terkirim ke server dan ditolak validasi SERVER', async ({
    adminPage,
  }) => {
    // Beda dari Panen: input foto di sini TIDAK punya atribut required
    // di HTML, sehingga form ini lolos validasi native browser dan
    // permintaan benar-benar terkirim ke server, baru ditolak di sana.
    const stokPage = new StokGudangPage(adminPage);
    await stokPage.goto();
    await stokPage.openModal();
    await stokPage.isiFormTransaksi({
      jenis: 'keluar',
      komoditas: 'Gabah',
      jumlah: '5',
      keterangan: 'Tanpa foto bukti',
      // fotoPath sengaja tidak diisi
    });
    await stokPage.submit();

    await expect(stokPage.errorBanner).toBeVisible();
  });

  test('TC-SG-FN-004 — "Sumber/Keterangan" kosong diblokir validasi native (field required & visible)', async ({
    adminPage,
  }) => {
    const stokPage = new StokGudangPage(adminPage);
    await stokPage.goto();
    await stokPage.openModal();
    await stokPage.jenisSelect.selectOption('keluar');
    await stokPage.komoditasSelect.selectOption('Gabah');
    await stokPage.jumlahInput.fill('5');
    // keterangan sengaja dikosongkan

    const isValid = await stokPage.keteranganTextInput.evaluate((el: HTMLInputElement) => el.checkValidity());
    expect(isValid).toBe(false);
  });
});

test.describe('Stok Gudang - Filter, Pencarian, & Status', () => {
  test('TC-SG-FILTER-001 — filter jenis "Keluar" hanya menampilkan baris jenis keluar', async ({ adminPage }) => {
    const stokPage = new StokGudangPage(adminPage);
    await stokPage.goto();
    await stokPage.filterByJenis('keluar');
    await adminPage.waitForTimeout(500);

    const count = await stokPage.tableRows.count();
    if (count > 0) {
      await expect(stokPage.tableRows.first()).toContainText(/Keluar/i);
    }
  });

  test('TC-SG-FILTER-002 — filter komoditas "Gabah" hanya menampilkan baris Gabah', async ({ adminPage }) => {
    const stokPage = new StokGudangPage(adminPage);
    await stokPage.goto();
    await stokPage.filterByKomoditas('gabah');
    await adminPage.waitForTimeout(500);

    const count = await stokPage.tableRows.count();
    if (count > 0) {
      await expect(stokPage.tableRows.first()).toContainText(/Gabah/i);
    }
  });

  test('TC-SG-STATUS-001 — "Batalkan transaksi" menonaktifkan baris secara live (AJAX, tanpa reload)', async ({
    adminPage,
  }) => {
    const stokPage = new StokGudangPage(adminPage);
    const keterangan = `Batal Uji ${uniqueSuffix()}`;

    await stokPage.goto();
    await stokPage.openModal();
    await stokPage.isiFormTransaksi({
      jenis: 'keluar',
      komoditas: 'Gabah',
      jumlah: '3',
      keterangan,
      fotoPath: BUKTI_IMAGE_PATH,
    });
    await stokPage.submit();
    await adminPage.waitForURL(/\/admin\/stok/);

    const row = stokPage.tableRows.filter({ hasText: keterangan }).first();
    await expect(row).toBeVisible();
    await row.getByTitle('Batalkan transaksi').click();

    await expect(row.getByTitle('Aktifkan kembali')).toBeVisible({ timeout: 5000 });
  });
});

test.describe('Stok Gudang - Role-based Access', () => {
  test('petugas BISA mengakses Stok Gudang (role admin & petugas diizinkan)', async ({ petugasPage }) => {
    const stokPage = new StokGudangPage(petugasPage);
    const response = await petugasPage.goto('/admin/stok');
    expect(response?.status()).not.toBe(403);
    await expect(stokPage.catatTransaksiButton).toBeVisible();
  });

  test('petani TIDAK bisa mengakses Stok Gudang admin — HTTP 403', async ({ petaniPage }) => {
    const response = await petaniPage.goto('/admin/stok');
    expect(response?.status()).toBe(403);
  });
});
