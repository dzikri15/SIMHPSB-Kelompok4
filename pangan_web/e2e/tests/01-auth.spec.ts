/**
 * 01-auth.spec.ts
 * ------------------------------------------------------------------
 * Menguji resources/views/auth/login.blade.php dan LoginController.
 * File ini SENGAJA tidak memakai fixtures/auth.fixtures.ts karena
 * justru menguji proses login itu sendiri (pakai `page` bawaan/guest).
 */
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { USERS } from '../fixtures/test-data';

test.describe('Halaman Login', () => {
  test('menampilkan form login dengan elemen yang benar', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();

    await expect(page).toHaveTitle(/Login/i);
    await expect(login.identifierInput).toBeVisible();
    await expect(login.passwordInput).toBeVisible();
    await expect(login.rememberCheckbox).toBeVisible();
    await expect(login.submitButton).toHaveText(/Masuk ke Dashboard/i);
  });

  test('menolak submit ketika identifier & password kosong (validasi HTML5)', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();

    await login.submitButton.click();
    // Browser tidak akan pindah halaman karena atribut `required` bawaan HTML5.
    await expect(page).toHaveURL(/\/login$/);
    await login.expectValidationMessage(login.identifierInput);
  });

  test('menampilkan pesan error saat kredensial salah', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();
    await login.login('admin@simhpsb.com', 'password-yang-salah');

    await expect(page).toHaveURL(/\/login$/);
    await login.expectLoginError();
  });

  test('menampilkan pesan error saat akun tidak ditemukan', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();
    await login.login('tidak.ada@example.com', 'password');

    await login.expectLoginError();
  });

  test('tombol mata bisa menampilkan & menyembunyikan password', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();
    await login.passwordInput.fill('rahasia123');

    await expect(login.passwordInput).toHaveAttribute('type', 'password');
    await login.togglePasswordButton.click();
    await expect(login.passwordInput).toHaveAttribute('type', 'text');
    await login.togglePasswordButton.click();
    await expect(login.passwordInput).toHaveAttribute('type', 'password');
  });

  test('login sukses sebagai admin diarahkan ke /admin', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();
    await login.login(USERS.admin.identifier, USERS.admin.password);

    await expect(page).toHaveURL(/\/admin(\/)?$/);
  });

  test('login sukses sebagai petugas diarahkan ke /petugas', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();
    await login.login(USERS.petugas.identifier, USERS.petugas.password);

    await expect(page).toHaveURL(/\/petugas(\/)?$/);
  });

  test('login sukses sebagai petani diarahkan ke /petani', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();
    await login.login(USERS.petani.identifier, USERS.petani.password);

    await expect(page).toHaveURL(/\/petani(\/)?$/);
  });

  test('checkbox "Ingat saya" bisa dicentang sebelum submit', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();
    await login.login(USERS.admin.identifier, USERS.admin.password, true);

    await expect(page).toHaveURL(/\/admin(\/)?$/);
    // Laravel menerbitkan cookie remember_web_* ketika remember=true
    const cookies = await page.context().cookies();
    expect(cookies.some((c) => c.name.startsWith('remember_web_'))).toBeTruthy();
  });
});

test.describe('Guard guest & redirect awal', () => {
  test('mengakses "/" tanpa login diarahkan ke /intro', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveURL(/\/intro$/);
  });

  test('pengguna yang sudah login tidak bisa membuka /login lagi (middleware guest)', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();
    await login.login(USERS.admin.identifier, USERS.admin.password);
    await expect(page).toHaveURL(/\/admin(\/)?$/);

    // Coba akses ulang /login selagi sesi admin masih aktif
    await page.goto('/login');
    await expect(page).not.toHaveURL(/\/login$/);
  });
});

test.describe('Logout', () => {
  test('logout mengakhiri sesi dan halaman admin tidak bisa diakses lagi', async ({ page }) => {
    const login = new LoginPage(page);
    await login.goto();
    await login.login(USERS.admin.identifier, USERS.admin.password);
    await expect(page).toHaveURL(/\/admin(\/)?$/);

    await page.locator('a.user-logout, a[title="Logout"]').click();
    await expect(page).toHaveURL(/\/(login|intro)?$/);

    // Setelah logout, mencoba buka /admin lagi harus dilempar ke /login
    await page.goto('/admin');
    await expect(page).toHaveURL(/\/login$/);
  });
});
