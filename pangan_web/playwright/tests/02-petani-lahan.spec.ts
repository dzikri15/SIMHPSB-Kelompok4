import { test, expect } from '../fixtures/auth';
import { PetaniPage } from '../pages/PetaniPage';
import { uniqueSuffix } from '../fixtures/test-data';

/**
 * =====================================================================
 * DATA PETANI & LAHAN — Test Suite
 * Sumber dokumentasi manual: "TC_Petani_Lahan.xlsx" & test-case-petani-lahan.md
 * Sumber kebenaran teknis: resources/views/admin/petani/index.blade.php,
 *   app/Http/Controllers/Admin/PetaniController.php
 *
 * TEMUAN PERBEDAAN UTAMA (lihat README.md untuk detail):
 *   1. Form "Tambah Petani" TIDAK memiliki field NIK. Sebagai
 *      gantinya, form membutuhkan Email + Password + Konfirmasi
 *      Password, karena menambah petani = membuat akun login
 *      sekaligus (lihat PetaniController@store baris 63-70).
 *      (Kolom `nik` masih ada di skema database, hanya sudah tidak
 *      diekspos lagi di form CRUD manapun.)
 *   2. Form ini dikirim via fetch() (AJAX). Kegagalan validasi
 *      SERVER (mis. email sudah dipakai) memicu window.alert()
 *      generik "Gagal menyimpan data. Silakan coba lagi." — BUKAN
 *      pesan validasi per-field inline seperti pada form biasa.
 *   3. Kegagalan validasi BROWSER (field required kosong) ditangani
 *      native oleh HTML5 sebelum request terkirim sama sekali.
 * =====================================================================
 */

test.describe('Data Petani - Functional Positive & Negative', () => {
  test('TC-PL-FP — admin berhasil menambah data petani baru lewat modal', async ({ adminPage }) => {
    const petaniPage = new PetaniPage(adminPage);
    const nama = `Petani Test ${uniqueSuffix()}`;
    const email = `petani.${uniqueSuffix()}@example.com`;

    await petaniPage.goto();
    await petaniPage.openTambahModal();
    await petaniPage.isiFormTambah({
      nama,
      telepon: '081234567890',
      email,
      password: 'password123',
      luasLahan: '5000',
      status: 'aktif',
      alamat: 'Desa Makmur, Kecamatan Sejahtera',
      catatan: 'Ditambahkan lewat automated test',
    });
    await petaniPage.submitTambah();

    // Sukses -> modal tertutup + location.reload() (lihat catatan AJAX di atas).
    await adminPage.waitForURL(/\/admin\/petani/, { timeout: 10000 });
    await adminPage.waitForLoadState('networkidle');
    await expect(petaniPage.rowByName(nama)).toBeVisible({ timeout: 10000 });
  });

  test('TC-PL-FN — email duplikat ditolak server, ditampilkan lewat dialog alert()', async ({ adminPage }) => {
    const petaniPage = new PetaniPage(adminPage);
    const nama1 = `Petani Dup A ${uniqueSuffix()}`;
    const email = `duplikat.${uniqueSuffix()}@example.com`;

    // Buat petani pertama dengan email X.
    await petaniPage.goto();
    await petaniPage.openTambahModal();
    await petaniPage.isiFormTambah({
      nama: nama1,
      email,
      password: 'password123',
      alamat: 'Alamat A',
    });
    await petaniPage.submitTambah();
    await adminPage.waitForLoadState('networkidle');
    await adminPage.waitForTimeout(700);

    // Coba buat petani KEDUA dengan email yang SAMA -> harus gagal.
    let alertMessage = '';
    adminPage.on('dialog', async (dialog) => {
      alertMessage = dialog.message();
      await dialog.accept();
    });

    await petaniPage.goto();
    await petaniPage.openTambahModal();
    await petaniPage.isiFormTambah({
      nama: `Petani Dup B ${uniqueSuffix()}`,
      email, // email sama persis
      password: 'password123',
      alamat: 'Alamat B',
    });
    await petaniPage.submitTambah();
    await adminPage.waitForTimeout(1000);

    expect(alertMessage).toContain('Gagal menyimpan data');
    // Modal seharusnya masih ada di DOM (tidak reload sukses).
    await expect(petaniPage.modalTambah).toBeVisible();
  });

  test('TC-PL-UI — field wajib kosong diblokir validasi native browser (modal tidak tertutup)', async ({ adminPage }) => {
    const petaniPage = new PetaniPage(adminPage);
    await petaniPage.goto();
    await petaniPage.openTambahModal();

    // Sengaja tidak mengisi "Nama Lengkap" (required) lalu langsung submit.
    await petaniPage.emailInput.fill(`kosong.${uniqueSuffix()}@example.com`);
    await petaniPage.passwordInput.fill('password123');
    await petaniPage.passwordConfirmationInput.fill('password123');
    await petaniPage.alamatTextarea.fill('Alamat lengkap');
    await petaniPage.submitTambah();

    // Validasi HTML5 native mencegah 'submit' event terkirim -> modal tetap terbuka.
    await expect(petaniPage.modalTambah).toBeVisible();
    await expect(adminPage).toHaveURL(/\/admin\/petani$/);
  });

  test('TC-PL-VAL — password & konfirmasi password tidak sama ditolak server', async ({ adminPage }) => {
    const petaniPage = new PetaniPage(adminPage);

    let alertMessage = '';
    adminPage.on('dialog', async (dialog) => {
      alertMessage = dialog.message();
      await dialog.accept();
    });

    await petaniPage.goto();
    await petaniPage.openTambahModal();
    await petaniPage.isiFormTambah({
      nama: `Petani Mismatch ${uniqueSuffix()}`,
      email: `mismatch.${uniqueSuffix()}@example.com`,
      password: 'password123',
      passwordConfirmation: 'password456',
      alamat: 'Alamat Mismatch',
    });
    await petaniPage.submitTambah();
    await adminPage.waitForTimeout(1000);

    expect(alertMessage).toContain('Gagal menyimpan data');
  });
});

test.describe('Data Petani - Search, Filter, Status, Delete', () => {
  test('TC-PL-SEARCH — pencarian nama petani memfilter tabel secara live (client-side)', async ({ adminPage }) => {
    const petaniPage = new PetaniPage(adminPage);
    await petaniPage.goto();

    const totalBefore = await petaniPage.tableRows.count();
    test.skip(totalBefore === 0, 'Tidak ada data petani untuk diuji pencarian.');

    const firstRowText = (await petaniPage.tableRows.first().locator('td').nth(1).textContent()) ?? '';
    const namaUnik = firstRowText.trim().split('\n')[0].trim();

    await petaniPage.filterByText(namaUnik.substring(0, 4));
    await expect(petaniPage.rowByName(namaUnik)).toBeVisible();
  });

  test('TC-PL-STATUS — klik kolom status men-toggle Aktif/Non-aktif tanpa reload (AJAX)', async ({ adminPage }) => {
    const petaniPage = new PetaniPage(adminPage);
    const nama = `Petani Toggle ${uniqueSuffix()}`;

    await petaniPage.goto();
    await petaniPage.openTambahModal();
    await petaniPage.isiFormTambah({
      nama,
      email: `toggle.${uniqueSuffix()}@example.com`,
      password: 'password123',
      status: 'aktif',
      alamat: 'Alamat Toggle',
    });
    await petaniPage.submitTambah();
    await adminPage.waitForLoadState('networkidle');
    await adminPage.waitForTimeout(700);
    await petaniPage.goto();

    const badge = petaniPage.statusBadgeForRow(nama);
    await expect(badge).toContainText('Aktif');

    await petaniPage.toggleStatusForRow(nama);
    await expect(badge).toContainText('Non-aktif', { timeout: 5000 });
  });

  test('TC-PL-DEL — hapus data petani menampilkan modal konfirmasi & menghapus setelah dikonfirmasi', async ({ adminPage }) => {
    const petaniPage = new PetaniPage(adminPage);
    const nama = `Petani Hapus ${uniqueSuffix()}`;

    await petaniPage.goto();
    await petaniPage.openTambahModal();
    await petaniPage.isiFormTambah({
      nama,
      email: `hapus.${uniqueSuffix()}@example.com`,
      password: 'password123',
      alamat: 'Alamat akan dihapus',
    });
    await petaniPage.submitTambah();
    await adminPage.waitForLoadState('networkidle');
    await adminPage.waitForTimeout(700);
    await petaniPage.goto();

    await expect(petaniPage.rowByName(nama)).toBeVisible();
    await petaniPage.deleteByName(nama);

    await adminPage.waitForURL(/\/admin\/petani/);
    await expect(adminPage.locator('.alert-success')).toContainText('berhasil dihapus');
    await expect(petaniPage.rowByName(nama)).toHaveCount(0);
  });

  test('TC-PL-EXPORT — tombol export PDF/Excel/CSV mengarah ke route export yang benar', async ({ adminPage }) => {
    const petaniPage = new PetaniPage(adminPage);
    await petaniPage.goto();

    await expect(petaniPage.exportPdfLink).toHaveAttribute('href', /format=pdf/);
    await expect(petaniPage.exportExcelLink).toHaveAttribute('href', /format=excel/);
    await expect(petaniPage.exportCsvLink).toHaveAttribute('href', /format=csv/);
  });
});

test.describe('Data Petani - Role-based Access (TC-SEC)', () => {
  // PENTING: Berdasarkan routes/web.php, seluruh grup /admin/* dibungkus
  // middleware `role:admin,petugas` di level TERLUAR (baris 77). Modul
  // Petani, Panen, Stok Gudang, dan Alert TIDAK mendapat pembatasan
  // tambahan yang lebih ketat, sehingga role PETUGAS SEBENARNYA BISA
  // mengakses /admin/petani — berbeda dari asumsi umum bahwa data
  // petani "khusus admin". Hanya modul Harga, Laporan, Pengguna, dan
  // Pengaturan yang dibatasi ketat dengan `role:admin` saja.
  test('petugas TERNYATA BISA mengakses /admin/petani (middleware role:admin,petugas di level grup)', async ({
    petugasPage,
  }) => {
    const response = await petugasPage.goto('/admin/petani');
    expect(response?.status()).not.toBe(403);
  });

  test('user yang belum login diarahkan ke halaman login saat akses /admin/petani', async ({ browser }) => {
    const context = await browser.newContext();
    const page = await context.newPage();
    await page.goto('/admin/petani');
    await expect(page).toHaveURL(/\/login/);
    await context.close();
  });

  test('petani (role petani) TIDAK bisa mengakses /admin/petani — HTTP 403', async ({ petaniPage }) => {
    const response = await petaniPage.goto('/admin/petani');
    expect(response?.status()).toBe(403);
  });

  test('admin melihat menu "Data Petani" di sidebar, role petani TIDAK melihatnya', async ({ adminPage, petaniPage: petaniLoggedInPage }) => {
    await expect(adminPage.getByRole('link', { name: /Data Petani/ })).toBeVisible();
    await expect(petaniLoggedInPage.getByRole('link', { name: /Data Petani/ })).toHaveCount(0);
  });
});
