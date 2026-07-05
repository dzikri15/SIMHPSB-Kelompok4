/**
 * 09-pengguna.spec.ts
 * ------------------------------------------------------------------
 * Menguji admin/pengguna/index.blade.php + create.blade.php.
 * Halaman ini HANYA bisa diakses role admin (lihat 02-rbac.spec.ts).
 */
import { test, expect } from '../fixtures/auth.fixtures';
import { PenggunaPage } from '../pages/PenggunaPage';
import { buildPenggunaPayload } from '../fixtures/test-data';

test.describe('Manajemen Pengguna — index', () => {
  test('menampilkan daftar pengguna', async ({ adminPage }) => {
    const pengguna = new PenggunaPage(adminPage);
    await pengguna.goto();

    await expect(pengguna.table).toBeVisible();
    await expect(pengguna.tambahLink).toBeVisible();
    await expect(pengguna.table).toContainText('admin@simhpsb.com');
  });

  test('admin tidak bisa menghapus akunnya sendiri', async ({ adminPage }) => {
    const pengguna = new PenggunaPage(adminPage);
    await pengguna.goto();

    await pengguna.openDeleteModal('Admin SIMHPSB');
    await pengguna.confirmDelete();

    await expect(adminPage.locator('body')).toContainText(/Tidak dapat menghapus akun yang sedang Anda gunakan/i);
    await expect(pengguna.table).toContainText('Admin SIMHPSB');
  });
});

test.describe('Manajemen Pengguna — tambah pengguna', () => {
  test('field "Pilih Petani Terhubung" hanya tampil & wajib saat role = petani', async ({ adminPage }) => {
    const pengguna = new PenggunaPage(adminPage);
    await pengguna.gotoCreate();

    await expect(pengguna.petaniField).toBeHidden();
    await expect(pengguna.petaniSelect).toBeDisabled();

    await pengguna.roleSelect.selectOption('petani');
    await expect(pengguna.petaniField).toBeVisible();
    await expect(pengguna.petaniSelect).toBeEnabled();
    await expect(pengguna.petaniSelect).toHaveAttribute('required', /.*/);

    await pengguna.roleSelect.selectOption('admin');
    await expect(pengguna.petaniField).toBeHidden();
    await expect(pengguna.petaniSelect).toBeDisabled();
  });

  test('berhasil membuat pengguna admin baru dan menampilkan modal password', async ({ adminPage }) => {
    const pengguna = new PenggunaPage(adminPage);
    const payload = buildPenggunaPayload();
    await pengguna.gotoCreate();

    await pengguna.fillForm({
      nama: payload.nama,
      email: payload.email,
      role: 'admin',
      password: payload.password,
      passwordConfirmation: payload.password,
    });
    await pengguna.submit();

    await expect(pengguna.modalPasswordBaru).toBeVisible();
    await expect(pengguna.passwordText).toHaveText(payload.password);

    await adminPage.locator('#modalPasswordBaru a', { hasText: 'Saya Sudah Menyalin Password' }).click();
    await expect(adminPage).toHaveURL(/\/admin\/pengguna$/);
    await expect(new PenggunaPage(adminPage).table).toContainText(payload.email);
  });

  test('berhasil membuat pengguna dengan role petani terhubung ke data petani', async ({ adminPage }) => {
    const pengguna = new PenggunaPage(adminPage);
    const payload = buildPenggunaPayload();
    await pengguna.gotoCreate();

    await pengguna.namaInput.fill(payload.nama);
    await pengguna.emailInput.fill(payload.email);
    await pengguna.roleSelect.selectOption('petani');
    await pengguna.petaniSelect.selectOption({ index: 1 }); // opsi pertama setelah placeholder
    await pengguna.passwordInput.fill(payload.password);
    await pengguna.passwordConfirmInput.fill(payload.password);
    await pengguna.submit();

    await expect(pengguna.modalPasswordBaru).toBeVisible();
  });

  test('menolak konfirmasi password yang tidak cocok', async ({ adminPage }) => {
    const pengguna = new PenggunaPage(adminPage);
    const payload = buildPenggunaPayload();
    await pengguna.gotoCreate();

    await pengguna.fillForm({
      nama: payload.nama,
      email: payload.email,
      role: 'petugas',
      password: payload.password,
      passwordConfirmation: 'tidak-cocok-samasekali',
    });
    await pengguna.submit();

    await expect(adminPage.locator('body')).toContainText(/confirmation|konfirmasi/i);
    await expect(pengguna.modalPasswordBaru).toBeHidden();
  });

  test('menolak password kurang dari 8 karakter', async ({ adminPage }) => {
    const pengguna = new PenggunaPage(adminPage);
    const payload = buildPenggunaPayload();
    await pengguna.gotoCreate();

    await pengguna.fillForm({
      nama: payload.nama,
      email: payload.email,
      role: 'petugas',
      password: 'pendek1',
      passwordConfirmation: 'pendek1',
    });
    await pengguna.submit();

    await expect(adminPage.locator('body')).toContainText(/8/);
  });

  test('menolak email yang sudah terdaftar', async ({ adminPage }) => {
    const pengguna = new PenggunaPage(adminPage);
    await pengguna.gotoCreate();

    await pengguna.fillForm({
      nama: 'Duplikat Email',
      email: 'petugas@simhpsb.com',
      role: 'petugas',
      password: 'password123',
      passwordConfirmation: 'password123',
    });
    await pengguna.submit();

    await expect(adminPage.locator('body')).toContainText(/email/i);
    await expect(pengguna.modalPasswordBaru).toBeHidden();
  });
});
