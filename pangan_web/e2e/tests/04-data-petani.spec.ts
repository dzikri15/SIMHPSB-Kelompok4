/**
 * 04-data-petani.spec.ts
 * ------------------------------------------------------------------
 * Menguji admin/petani/index, create, edit, show.
 *
 * CATATAN PENTING (dari PetaniController@store): setiap kali petani baru
 * dibuat lewat form ini, sistem OTOMATIS membuat juga akun User dengan
 * role 'petani' dan email/password YANG SAMA seperti yang diisi di form
 * ini — bukan lewat modul Manajemen Pengguna. Ini dipakai lagi di
 * 13-petani-dashboard.spec.ts untuk menguji dashboard petani dengan akun
 * yang benar-benar terhubung.
 */
import { test, expect } from '../fixtures/auth.fixtures';
import { DataPetaniPage } from '../pages/DataPetaniPage';
import { buildPetaniPayload } from '../fixtures/test-data';

test.describe('Data Petani — index', () => {
  test('menampilkan daftar petani dan tombol aksi', async ({ adminPage }) => {
    const petaniPage = new DataPetaniPage(adminPage);
    await petaniPage.goto();

    await expect(petaniPage.table).toBeVisible();
    await expect(petaniPage.tambahButton).toBeVisible();
    for (const format of ['PDF', 'Excel', 'CSV'] as const) {
      await expect(petaniPage.exportLink(format)).toBeVisible();
    }
  });

  test('pencarian client-side menyaring baris tabel', async ({ adminPage }) => {
    const petaniPage = new DataPetaniPage(adminPage);
    await petaniPage.goto();

    const totalSebelum = await petaniPage.visibleRowCount();
    await petaniPage.search('zzz_nama_yang_pasti_tidak_ada_zzz');
    await expect(petaniPage.table.locator('tbody tr:visible')).toHaveCount(0);

    await petaniPage.search('');
    expect(await petaniPage.visibleRowCount()).toBe(totalSebelum);
  });
});

test.describe('Data Petani — tambah lewat modal', () => {
  test('berhasil menambah petani baru dengan data valid', async ({ adminPage }) => {
    const petaniPage = new DataPetaniPage(adminPage);
    const payload = buildPetaniPayload();
    await petaniPage.goto();

    await petaniPage.openTambahModal();
    await petaniPage.fillModalForm({
      nama: payload.nama,
      telepon: payload.telepon,
      email: payload.email,
      password: payload.password,
      passwordConfirmation: payload.password,
      luasLahan: payload.luasLahan,
      alamat: payload.alamat,
    });
    await petaniPage.submitModalForm();

    await expect(adminPage).toHaveURL(/\/admin\/petani$/);
    await expect(adminPage.locator('body')).toContainText(/berhasil ditambahkan/i);
    await expect(petaniPage.rowByName(payload.nama)).toBeVisible();
  });

  test('menolak submit ketika field wajib kosong (validasi HTML5)', async ({ adminPage }) => {
    const petaniPage = new DataPetaniPage(adminPage);
    await petaniPage.goto();
    await petaniPage.openTambahModal();

    // Langsung submit tanpa mengisi apa pun
    await petaniPage.submitModalForm();

    // Modal tetap terbuka karena browser menahan submit (required attr)
    await petaniPage.expectModalOpen('modalTambah');
  });

  test('menampilkan error server saat konfirmasi password tidak cocok', async ({ adminPage }) => {
    const petaniPage = new DataPetaniPage(adminPage);
    const payload = buildPetaniPayload();
    await petaniPage.goto();

    await petaniPage.openTambahModal();
    await petaniPage.fillModalForm({
      nama: payload.nama,
      email: payload.email,
      password: payload.password,
      passwordConfirmation: 'password-tidak-cocok',
      luasLahan: payload.luasLahan,
      alamat: payload.alamat,
    });
    await petaniPage.submitModalForm();

    // Validasi 'confirmed' gagal di server → redirect back dengan $errors
    await expect(adminPage.locator('body')).toContainText(/confirmation|konfirmasi/i);
  });

  test('menolak email yang sudah terdaftar (unique)', async ({ adminPage }) => {
    const petaniPage = new DataPetaniPage(adminPage);
    await petaniPage.goto();
    await petaniPage.openTambahModal();
    await petaniPage.fillModalForm({
      nama: 'Duplikat Email Test',
      email: 'admin@simhpsb.com', // sudah dipakai akun admin bawaan
      password: 'password123',
      passwordConfirmation: 'password123',
      alamat: 'Alamat apa saja',
    });
    await petaniPage.submitModalForm();

    await expect(adminPage.locator('body')).toContainText(/email/i);
    await expect(adminPage).not.toHaveURL(/admin\/petani\/\d+/);
  });
});

test.describe('Data Petani — tambah lewat halaman penuh (create page)', () => {
  test('berhasil menambah petani lewat /admin/petani/create', async ({ adminPage }) => {
    const petaniPage = new DataPetaniPage(adminPage);
    const payload = buildPetaniPayload();
    await petaniPage.gotoCreatePage();

    await petaniPage.fillFullPageForm({
      nama: payload.nama,
      alamat: payload.alamat,
      telepon: payload.telepon,
      email: payload.email,
      password: payload.password,
      passwordConfirmation: payload.password,
      luasLahan: payload.luasLahan,
    });
    await petaniPage.submitFullPageForm();

    await expect(adminPage).toHaveURL(/\/admin\/petani$/);
    await expect(petaniPage.rowByName(payload.nama)).toBeVisible();
  });
});

test.describe('Data Petani — edit, detail, hapus, toggle status', () => {
  async function seedPetani(adminPage: import('@playwright/test').Page) {
    const petaniPage = new DataPetaniPage(adminPage);
    const payload = buildPetaniPayload();
    await petaniPage.goto();
    await petaniPage.openTambahModal();
    await petaniPage.fillModalForm({
      nama: payload.nama,
      email: payload.email,
      password: payload.password,
      passwordConfirmation: payload.password,
      luasLahan: payload.luasLahan,
      alamat: payload.alamat,
    });
    await petaniPage.submitModalForm();
    return { petaniPage, payload };
  }

  test('mengubah data petani lewat form edit', async ({ adminPage }) => {
    const { petaniPage, payload } = await seedPetani(adminPage);
    const namaBaru = `${payload.nama} (Diubah)`;

    await petaniPage.openEdit(payload.nama);
    await adminPage.getByLabel('Nama Petani').fill(namaBaru);
    await adminPage.locator('button[type="submit"]').click();

    await expect(adminPage).toHaveURL(/\/admin\/petani$/);
    await expect(petaniPage.rowByName(namaBaru)).toBeVisible();
  });

  test('membuka halaman detail petani', async ({ adminPage }) => {
    const { petaniPage, payload } = await seedPetani(adminPage);

    await petaniPage.openDetail(payload.nama);
    await expect(adminPage.locator('body')).toContainText(payload.nama);
    await expect(adminPage.locator('body')).toContainText(/Detail Petani/i);
  });

  test('toggle status aktif/nonaktif lewat klik sel status', async ({ adminPage }) => {
    const { petaniPage, payload } = await seedPetani(adminPage);
    const row = petaniPage.rowByName(payload.nama);
    await expect(row.locator('.badge')).toContainText(/Aktif/i);

    await petaniPage.toggleStatus(payload.nama);
    await expect(row.locator('.badge')).toContainText(/Non-aktif/i);

    // Klik sekali lagi harus kembali aktif
    await petaniPage.toggleStatus(payload.nama);
    await expect(row.locator('.badge')).toContainText(/Aktif/i);
  });

  test('menghapus data petani lewat modal konfirmasi', async ({ adminPage }) => {
    const { petaniPage, payload } = await seedPetani(adminPage);

    await petaniPage.openDeleteModal(payload.nama);
    await petaniPage.confirmDelete();

    await expect(adminPage).toHaveURL(/\/admin\/petani$/);
    await expect(petaniPage.rowByName(payload.nama)).toHaveCount(0);
  });

  test('modal hapus bisa dibatalkan tanpa menghapus data', async ({ adminPage }) => {
    const { petaniPage, payload } = await seedPetani(adminPage);

    await petaniPage.openDeleteModal(payload.nama);
    await adminPage.locator('#modalHapus button', { hasText: 'Batal' }).click();
    await petaniPage.expectModalClosed('modalHapus');

    await expect(petaniPage.rowByName(payload.nama)).toBeVisible();
  });
});
