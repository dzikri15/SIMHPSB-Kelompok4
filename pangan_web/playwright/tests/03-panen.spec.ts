import { test, expect } from '../fixtures/auth';
import { PanenPage } from '../pages/PanenPage';
import { BUKTI_IMAGE_PATH } from '../fixtures/test-data';

/**
 * =====================================================================
 * PENCATATAN PANEN — Test Suite
 * Sumber dokumentasi manual: "Test Case Input Data Panen.xlsx"
 * Sumber kebenaran teknis: resources/views/admin/panen/index.blade.php,
 *   app/Http/Controllers/Admin/PanenController.php
 *
 * TEMUAN PERBEDAAN UTAMA (lihat README.md untuk detail):
 *   1. TIDAK ADA field "Rasio Konversi (%)" sama sekali pada kode
 *      sumber saat ini. Kolom `konversi_beras` di database di-hardcode
 *      ke 0 saat insert (PanenController@store baris 78).
 *   2. Field "Foto Bukti Panen" kini WAJIB (validasi:
 *      required|image|mimes:jpg,jpeg,png|max:5120).
 *   3. Mencatat panen OTOMATIS membuat entri "Gabah Masuk" baru di
 *      modul Stok Gudang (integrasi lintas modul) — ini adalah
 *      perilaku BARU yang tidak dijelaskan di dokumentasi awal.
 *   4. Dropdown Petani adalah komponen pencarian custom, bukan
 *      <select> HTML biasa.
 *   5. Tabel riwayat memakai kolom: Petani, Hasil Gabah, Penghasilan
 *      (Rp), Foto, Musim, Tanggal, Aksi — BUKAN "Beras Hasil".
 * =====================================================================
 */

test.describe('Panen - Functional Positive', () => {
  test('TC-PN-FP-001 — admin berhasil mencatat panen baru dengan foto bukti, otomatis update Stok Gudang', async ({
    adminPage,
  }) => {
    const panenPage = new PanenPage(adminPage);
    await panenPage.goto();

    await panenPage.isiFormPanen({
      petani: 'Pak Budi',
      musim: 'Kemarau',
      tanggalPanen: new Date().toISOString().slice(0, 10),
      jumlahGabah: '150',
      catatan: 'Panen automated test',
      fotoPath: BUKTI_IMAGE_PATH,
    });
    await panenPage.submit();

    await adminPage.waitForURL(/\/admin\/panen/);
    await expect(adminPage.locator('.alert-banner.success')).toContainText(
      'Data panen berhasil ditambahkan dan Gabah Masuk otomatis tercatat di Stok Gudang'
    );
  });
});

test.describe('Panen - Functional Negative', () => {
  test('TC-PN-FN-001 — submit tanpa foto bukti diblokir validasi native browser (field required, tidak terkirim ke server)', async ({
    adminPage,
  }) => {
    // Catatan: input file foto_bukti memiliki atribut HTML `required`.
    // Berbeda dari <input type="hidden">, atribut required pada
    // <input type="file"> TETAP divalidasi native oleh browser
    // meskipun elemen disembunyikan lewat CSS (display:none) — Chromium
    // tetap mencegah submit meski tanpa menampilkan bubble visual.
    // Karena itu, request TIDAK PERNAH sampai ke server, dan banner
    // error server-side (`.alert-banner.danger`) tidak akan muncul.
    const panenPage = new PanenPage(adminPage);
    await panenPage.goto();

    await panenPage.pilihPetani('Pak Budi');
    await panenPage.musimSelect.selectOption('Kemarau');
    await panenPage.tanggalPanenInput.fill(new Date().toISOString().slice(0, 10));
    await panenPage.jumlahGabahInput.fill('100');
    await panenPage.submit();

    const isValid = await panenPage.fotoBuktiInput.evaluate((el: HTMLInputElement) => el.checkValidity());
    expect(isValid).toBe(false);
    await expect(adminPage).toHaveURL(/\/admin\/panen$/);
  });

  test('TC-PN-FN-002 — jumlah gabah kurang dari batas minimum (min="1") diblokir validasi native browser', async ({
    adminPage,
  }) => {
    const panenPage = new PanenPage(adminPage);
    await panenPage.goto();

    await panenPage.pilihPetani('Pak Budi');
    await panenPage.musimSelect.selectOption('Hujan');
    await panenPage.tanggalPanenInput.fill(new Date().toISOString().slice(0, 10));
    await panenPage.jumlahGabahInput.fill('0');
    await panenPage.fotoBuktiInput.setInputFiles(BUKTI_IMAGE_PATH);
    await panenPage.submit();

    const isValid = await panenPage.jumlahGabahInput.evaluate((el: HTMLInputElement) => el.checkValidity());
    expect(isValid).toBe(false);
    await expect(adminPage).toHaveURL(/\/admin\/panen$/);
  });

  test('TC-PN-FN-003 — jumlah gabah berisi teks (bukan angka) ditolak native oleh input type=number', async ({
    adminPage,
  }) => {
    const panenPage = new PanenPage(adminPage);
    await panenPage.goto();

    await panenPage.pilihPetani('Pak Budi');
    await panenPage.musimSelect.selectOption('Kemarau');
    await panenPage.jumlahGabahInput.fill('abc');

    // Browser menolak karakter non-numerik pada <input type="number">,
    // sehingga value yang tersimpan tetap string kosong.
    await expect(panenPage.jumlahGabahInput).toHaveValue('');
  });

  test('TC-PN-FN-004 — tidak memilih petani ditolak validasi SERVER (hidden input tidak tervalidasi native)', async ({
    adminPage,
  }) => {
    // Berbeda dari field foto/jumlah di atas, petani_id adalah
    // <input type="hidden">. Elemen hidden DIKECUALIKAN dari
    // constraint validation HTML5 (berdasarkan spesifikasi WHATWG:
    // "barred from constraint validation"), sehingga meskipun ada
    // atribut `required`, browser TETAP mengizinkan submit — validasi
    // baru terjadi di sisi server (Laravel), dan barulah muncul
    // `.alert-banner.danger`.
    const panenPage = new PanenPage(adminPage);
    await panenPage.goto();

    await panenPage.musimSelect.selectOption('Kemarau');
    await panenPage.tanggalPanenInput.fill(new Date().toISOString().slice(0, 10));
    await panenPage.jumlahGabahInput.fill('100');
    await panenPage.fotoBuktiInput.setInputFiles(BUKTI_IMAGE_PATH);
    await panenPage.submit();

    await expect(panenPage.errorBanner).toBeVisible();
  });

  test('TC-PN-FN-005 — upload file bukan gambar (.txt) lolos validasi native tapi ditolak validasi mimes di server', async ({
    adminPage,
  }) => {
    const panenPage = new PanenPage(adminPage);
    await panenPage.goto();

    await panenPage.pilihPetani('Pak Budi');
    await panenPage.musimSelect.selectOption('Kemarau');
    await panenPage.tanggalPanenInput.fill(new Date().toISOString().slice(0, 10));
    await panenPage.jumlahGabahInput.fill('100');
    await panenPage.fotoBuktiInput.setInputFiles({
      name: 'bukti-invalid.txt',
      mimeType: 'text/plain',
      buffer: Buffer.from('ini bukan gambar'),
    });
    await panenPage.submit();

    await expect(panenPage.errorBanner).toBeVisible();
  });
});

test.describe('Panen - UI & Integrasi', () => {
  test('TC-PN-UI-001 — dropdown pencarian petani memfilter opsi sesuai ketikan', async ({ adminPage }) => {
    const panenPage = new PanenPage(adminPage);
    await panenPage.goto();

    await panenPage.petaniDisplay.click();
    await panenPage.petaniSearchInput.fill('Budi');

    await expect(adminPage.locator('li.petani-opt', { hasText: 'Budi' })).toBeVisible();
  });

  test('TC-PN-UI-002 — riwayat panen menampilkan data terbaru setelah pencatatan berhasil', async ({ adminPage }) => {
    const panenPage = new PanenPage(adminPage);
    await panenPage.goto();

    const tanggal = new Date().toISOString().slice(0, 10);
    await panenPage.isiFormPanen({
      petani: 'Bu Sari',
      musim: 'Hujan',
      tanggalPanen: tanggal,
      jumlahGabah: '75.5',
      fotoPath: BUKTI_IMAGE_PATH,
    });
    await panenPage.submit();
    await adminPage.waitForURL(/\/admin\/panen/);

    await expect(panenPage.rowForPetani('Bu Sari').first()).toBeVisible();
  });
});

test.describe('Panen - Role-based Access', () => {
  test('petugas BISA mengakses Pencatatan Panen (role admin & petugas diizinkan)', async ({ petugasPage }) => {
    const panenPage = new PanenPage(petugasPage);
    await panenPage.goto();
    await expect(petugasPage).toHaveURL(/\/admin\/panen|\/petugas\/panen/);
  });

  test('petani TIDAK bisa mengakses halaman Pencatatan Panen admin — HTTP 403', async ({ petaniPage }) => {
    const response = await petaniPage.goto('/admin/panen');
    expect(response?.status()).toBe(403);
  });
});
