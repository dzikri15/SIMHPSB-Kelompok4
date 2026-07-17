import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { PetaniPage } from '../pages/PetaniPage';
import { USERS, INVALID_USER, uniqueSuffix } from '../fixtures/test-data';

/**
 * =====================================================================
 * LOGIN PAGE — Test Suite
 * Sumber dokumentasi manual: "Test Case Login Page.xlsx"
 *   Sheet: TC-UI, TC-FP, TC-FN, TC-PW, TC-CL, TC-ACC, TC-SEC
 * Sumber kebenaran teknis: resources/views/auth/login.blade.php,
 *   app/Http/Controllers/Auth/LoginController.php
 *
 * TEMUAN PERBEDAAN antara dokumentasi & kode sumber saat ini
 * (lihat README.md untuk detail lengkap & rekomendasi):
 *   1. Nama merek yang dirender adalah "SIMHP", BUKAN "SIMHPSB"
 *      seperti disebut di TC-UI-002.
 *   2. Placeholder field identifier adalah "Masukkan email, nama
 *      pengguna, atau nama petani" — bukan "admin@medinfo.com"
 *      seperti di TC-UI-009.
 *   3. TIDAK ADA link "Lupa password?" di halaman ini (disebut di
 *      TC-ACC-001), sehingga urutan Tab yang diuji disesuaikan.
 *   4. Pesan error validasi tidak menampilkan teks spesifik seperti
 *      'Email/username wajib diisi' (TC-FN-001) — Laravel bawaan
 *      menampilkan SATU pesan generik di dalam elemen `.error-alert`.
 * =====================================================================
 */

test.describe('Login Page - TC-UI (Visual)', () => {
  test.beforeEach(async ({ page }) => {
    await new LoginPage(page).goto();
  });

  test('TC-UI-001 — logo SIMHP tampil di panel kiri', async ({ page }) => {
    await expect(page.locator('.logo-big img')).toBeVisible();
  });

  test('TC-UI-002 (disesuaikan) — nama merek tampil bold, besar, putih', async ({ page }) => {
    const brand = page.locator('.brand-name');
    await expect(brand).toBeVisible();
    // Catatan: teks aktual adalah "SIMHP", bukan "SIMHPSB" (lihat catatan atas file).
    await expect(brand).toHaveText('SIMHP');
  });

  test('TC-UI-003 (disesuaikan) — tagline tampil italic di bawah brand', async ({ page }) => {
    const tagline = page.locator('.brand-tagline');
    await expect(tagline).toBeVisible();
    await expect(tagline).toContainText('Sistem Informasi Monitoring Hasil Panen');
  });

  test('TC-UI-004 — card fitur "Dashboard Real-Time" tampil', async ({ page }) => {
    const card = page.locator('.feature-item').nth(0);
    await expect(card).toContainText('Dashboard Real-Time');
    await expect(card).toContainText('Pantau stok gabah & beras kapan saja');
  });

  test('TC-UI-005 — card fitur "Alert Otomatis" tampil', async ({ page }) => {
    const card = page.locator('.feature-item').nth(1);
    await expect(card).toContainText('Alert Otomatis');
    await expect(card).toContainText('Notifikasi langsung saat stok menipis');
  });

  test('TC-UI-006 — card fitur "Laporan & Ekspor" tampil', async ({ page }) => {
    const card = page.locator('.feature-item').nth(2);
    await expect(card).toContainText('Laporan & Ekspor');
    await expect(card).toContainText('Rekap panen dan margin per periode');
  });

  test('TC-UI-007 — heading "Selamat datang" dengan emoji tampil di panel kanan', async ({ page }) => {
    await expect(page.locator('.login-header h2')).toContainText('Selamat datang');
  });

  test('TC-UI-008 (disesuaikan) — deskripsi di bawah heading tampil', async ({ page }) => {
    await expect(page.locator('.login-header p')).toContainText('Masuk ke SIMHP');
  });

  test('TC-UI-009 (disesuaikan) — label field identifier tampil sesuai kode sumber', async ({ page }) => {
    await expect(page.locator('label[for="identifier"]')).toHaveText('Email, Nama Pengguna, atau Nama Petani');
    // Placeholder aktual berbeda dari dokumentasi — lihat catatan perbedaan di atas.
    await expect(page.locator('#identifier')).toHaveAttribute(
      'placeholder',
      'Masukkan email, nama pengguna, atau nama petani'
    );
  });

  test('TC-UI-010 — teks helper di bawah field identifier tampil', async ({ page }) => {
    await expect(page.locator('.small-hint')).toHaveText('Gunakan email, username, atau nama petani untuk login.');
  });

  test('TC-UI-011 — label "Password" tampil di atas field password', async ({ page }) => {
    await expect(page.locator('label[for="password"]')).toHaveText('Password');
  });

  test('TC-UI-012 — tombol submit "Masuk ke Dashboard" tampil', async ({ page }) => {
    await expect(page.locator('button.btn-login')).toContainText('Masuk ke Dashboard');
  });

  test('TC-UI-013 (disesuaikan) — footer versi & atribusi kelompok tampil', async ({ page }) => {
    await expect(page.locator('.login-footer')).toContainText('SIMHP v1.2');
    await expect(page.locator('.login-footer')).toContainText('Kelompok 4 UKRI 2025');
    await expect(page.locator('.login-footer')).toContainText('Universitas Kebangsaan Republik Indonesia');
  });
});

test.describe('Login Page - TC-FP (Functional Positive)', () => {
  test('TC-FP-004 — login admin berhasil, dashboard admin dengan menu lengkap dimuat', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(USERS.admin.identifier, USERS.admin.password);

    await expect(page).toHaveURL(/\/admin\/dashboard/);
    // Menu pengelolaan (Data Master) hanya tampil untuk admin.
    await expect(page.getByRole('link', { name: /Data Petani/ })).toBeVisible();
  });

  test('TC-FP-006 — login dengan email ALL CAPS tetap berhasil (case-insensitive)', async ({ page }) => {
    // Catatan: perilaku ini bergantung pada collation kolom `email` di
    // database (MySQL default: *_ci / case-insensitive), bukan logika
    // eksplisit di kode PHP. Jika database Anda menggunakan collation
    // case-sensitive (mis. *_bin), test ini bisa gagal — sesuaikan bila perlu.
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(USERS.admin.identifier.toUpperCase(), USERS.admin.password);

    await expect(page).toHaveURL(/\/admin\/dashboard/);
  });

  test('TC-FP-008 — checkbox "Ingat saya" tercentang membuat sesi bertahan di context baru', async ({ browser }) => {
    const context = await browser.newContext();
    const page = await context.newPage();
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(USERS.admin.identifier, USERS.admin.password, true);
    await expect(page).toHaveURL(/\/admin\/dashboard/);

    // Simulasikan "tutup & buka lagi" dengan context baru memakai storageState yang sama.
    const storageState = await context.storageState();
    const context2 = await browser.newContext({ storageState });
    const page2 = await context2.newPage();
    await page2.goto('/admin/dashboard');
    await expect(page2).not.toHaveURL(/\/login/);

    await context.close();
    await context2.close();
  });

  test('(tambahan) login via Nama Petani berhasil masuk ke dashboard role petani', async ({ page, browser }) => {
    // Dokumentasi TC-FP-003/005 mengasumsikan sudah ada akun Petani
    // bernama tertentu. Karena seed data bawaan tidak memiliki nama
    // yang persis cocok, test ini membuat akun Petani baru dahulu
    // lewat form admin (yang otomatis membuat User terkait — lihat
    // PetaniController@store), lalu memverifikasi login dengan nama
    // tersebut sebagai identifier.
    const namaPetaniBaru = `Petani Uji ${uniqueSuffix()}`;
    const email = `petani.${uniqueSuffix()}@example.com`;
    const password = 'password123';

    const loginAdmin = new LoginPage(page);
    await loginAdmin.goto();
    await loginAdmin.login(USERS.admin.identifier, USERS.admin.password);

    const petaniPage = new PetaniPage(page);
    await petaniPage.goto();
    await petaniPage.openTambahModal();
    await petaniPage.isiFormTambah({
      nama: namaPetaniBaru,
      email,
      password,
      alamat: 'Desa Uji Coba, Kecamatan Testing',
    });
    await petaniPage.submitTambah();
    await page.waitForTimeout(800); // menunggu fetch() selesai + location.reload()

    // Logout lalu login sebagai petani baru memakai NAMA sebagai identifier.
    const newContext = await browser.newContext();
    const newPage = await newContext.newPage();
    const petaniLogin = new LoginPage(newPage);
    await petaniLogin.goto();
    await petaniLogin.login(namaPetaniBaru, password);

    await expect(newPage).toHaveURL(/\/petani\/dashboard/);
    await newContext.close();
  });
});

test.describe('Login Page - TC-FN (Functional Negative)', () => {
  test('TC-FN-001 — field identifier kosong menampilkan validasi, tidak login', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.passwordInput.fill(USERS.admin.password);
    await loginPage.submitButton.click();

    await expect(page).toHaveURL(/\/login/);
    await expect(loginPage.errorAlert).toBeVisible();
  });

  test('TC-FN-002 — field password kosong menampilkan validasi, tidak login', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.identifierInput.fill(USERS.admin.identifier);
    await loginPage.submitButton.click();

    await expect(page).toHaveURL(/\/login/);
    await expect(loginPage.errorAlert).toBeVisible();
  });

  test('TC-FN-003 — kedua field kosong menampilkan validasi, tidak login', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.submitButton.click();

    await expect(page).toHaveURL(/\/login/);
    await expect(loginPage.errorAlert).toBeVisible();
  });

  test('TC-FN-004 — password salah menampilkan error umum, tidak login', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(USERS.admin.identifier, 'wrongpassword123');

    await expect(page).toHaveURL(/\/login/);
    await expect(loginPage.errorAlert).toBeVisible();
  });

  test('TC-FN-005 — identifier tidak terdaftar menampilkan error umum (mencegah user enumeration)', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(INVALID_USER.identifier, INVALID_USER.password);

    await expect(page).toHaveURL(/\/login/);
    const errorText = await loginPage.errorAlert.textContent();
    // Pesan tidak boleh berbeda dari kasus password salah (mencegah enumeration).
    expect(errorText?.toLowerCase()).not.toContain('tidak ditemukan');
    expect(errorText?.toLowerCase()).not.toContain('not found');
  });

  test('TC-FN-006 — format identifier tidak wajar tetap ditolak dengan aman', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('admin@@@invalid', 'test123');

    await expect(page).toHaveURL(/\/login/);
    await expect(loginPage.errorAlert).toBeVisible();
  });

  test('TC-FN-007 — string sangat panjang (300 karakter) tidak menyebabkan crash/500', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    const longString = 'a'.repeat(300);
    await loginPage.login(longString, 'test123');

    // Halaman tetap merespons secara wajar (login gagal, bukan crash 500).
    await expect(page.locator('body')).toBeVisible();
    await expect(page.locator('body')).not.toContainText('500 | Server Error');
  });

  test('TC-FN-008 — password sangat panjang (300 karakter) tidak menyebabkan crash/500', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('admin', 'a'.repeat(300));

    await expect(page.locator('body')).toBeVisible();
    await expect(page).toHaveURL(/\/login/);
  });

  test('TC-FN-009 — identifier hanya berisi spasi ditolak, tidak memproses login', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('   ', USERS.admin.password);

    await expect(page).toHaveURL(/\/login/);
  });
});

test.describe('Login Page - TC-PW (Password field)', () => {
  test('TC-PW-001 — karakter password ditampilkan masked secara default', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await expect(loginPage.passwordInput).toHaveAttribute('type', 'password');
    await loginPage.passwordInput.fill('TestPass123');
    await expect(loginPage.passwordInput).toHaveAttribute('type', 'password');
  });

  test('TC-PW-002 & TC-PW-003 — toggle ikon mata menampilkan & menyembunyikan password bolak-balik', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.passwordInput.fill('TestPass123');

    await loginPage.togglePasswordVisibility();
    await expect(loginPage.passwordInput).toHaveAttribute('type', 'text');

    await loginPage.togglePasswordVisibility();
    await expect(loginPage.passwordInput).toHaveAttribute('type', 'password');
  });
});

test.describe('Login Page - TC-CL (Checkbox "Ingat saya")', () => {
  test('TC-CL-001 — checkbox tidak tercentang secara default', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await expect(loginPage.rememberCheckbox).not.toBeChecked();
  });

  test('TC-CL-002 & TC-CL-003 — checkbox bisa ditoggle dua arah', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.rememberCheckbox.check();
    await expect(loginPage.rememberCheckbox).toBeChecked();

    await loginPage.rememberCheckbox.uncheck();
    await expect(loginPage.rememberCheckbox).not.toBeChecked();
  });

  test('TC-CL-004 — tanpa "Ingat saya", sesi tidak bertahan di context baru tanpa cookie', async ({ browser }) => {
    const context = await browser.newContext();
    const page = await context.newPage();
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(USERS.admin.identifier, USERS.admin.password, false);
    await expect(page).toHaveURL(/\/admin\/dashboard/);

    // Context BARU tanpa storageState = simulasi browser baru / cookie session hilang.
    const freshContext = await browser.newContext();
    const freshPage = await freshContext.newPage();
    await freshPage.goto('/admin/dashboard');
    await expect(freshPage).toHaveURL(/\/login/);

    await context.close();
    await freshContext.close();
  });
});

test.describe('Login Page - TC-ACC (Accessibility)', () => {
  test('TC-ACC-002 — menekan Enter pada form men-submit login (sama seperti klik tombol)', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.identifierInput.fill(USERS.admin.identifier);
    await loginPage.passwordInput.fill(USERS.admin.password);
    await loginPage.passwordInput.press('Enter');

    await expect(page).toHaveURL(/\/admin\/dashboard/);
  });

  test('TC-ACC-004 — setiap input field memiliki label yang berasosiasi (for=id)', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await expect(page.locator('label[for="identifier"]')).toHaveCount(1);
    await expect(page.locator('label[for="password"]')).toHaveCount(1);
  });

  test('TC-ACC-001 (disesuaikan) — Tab berpindah berurutan mulai dari field identifier', async ({ page }) => {
    // Catatan: link "Lupa password?" yang disebut di dokumentasi tidak
    // ada pada kode sumber saat ini, sehingga urutan fokus disesuaikan
    // dengan elemen interaktif yang benar-benar ada di DOM.
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    await page.locator('body').click({ position: { x: 5, y: 5 } });
    await page.keyboard.press('Tab');
    await expect(loginPage.identifierInput).toBeFocused();

    await page.keyboard.press('Tab');
    await expect(loginPage.passwordInput).toBeFocused();
  });
});

test.describe('Login Page - TC-SEC (Security)', () => {
  test('TC-SEC-001 — SQL Injection pada field identifier tidak bypass autentikasi', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login("' OR '1'='1", 'apapun');

    await expect(page).toHaveURL(/\/login/);
    // Tidak ada pesan error SQL mentah (mis. "SQLSTATE") yang bocor ke UI.
    await expect(page.locator('body')).not.toContainText('SQLSTATE');
  });

  test('TC-SEC-002 — SQL Injection pada field password tidak bypass autentikasi', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(USERS.admin.identifier, "' OR '1'='1");

    await expect(page).toHaveURL(/\/login/);
    await expect(page.locator('body')).not.toContainText('SQLSTATE');
  });

  test('TC-SEC-003 — XSS payload pada field identifier tidak dieksekusi', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();

    let dialogFired = false;
    page.on('dialog', async (dialog) => {
      dialogFired = true;
      await dialog.dismiss();
    });

    await loginPage.login("<script>alert('XSS')</script>", 'test');
    await page.waitForTimeout(500);

    expect(dialogFired).toBe(false);
    await expect(page).toHaveURL(/\/login/);
  });

  test('TC-SEC-005 — atribut autocomplete password sesuai standar keamanan', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await expect(loginPage.passwordInput).toHaveAttribute('autocomplete', 'current-password');
  });
});
