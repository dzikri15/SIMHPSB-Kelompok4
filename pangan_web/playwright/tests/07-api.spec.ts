import { test, expect } from '@playwright/test';
import { USERS } from '../fixtures/test-data';

/**
 * =====================================================================
 * API & AKSES TANPA SESI (TC-API) — Test Suite
 * Sumber dokumentasi manual: "Test Case Postman.xlsx"
 * Sumber kebenaran teknis: routes/web.php, routes/api.php,
 *   app/Http/Controllers/AuthController.php,
 *   app/Http/Middleware/RoleMiddleware.php
 *
 * CATATAN PENTING:
 *   Dokumentasi menyebut judul halaman login sebagai
 *   "<title>Login - SIMHPSB</title>". Kode sumber sebenarnya
 *   merender "<title>Login – SIMHP</title>" (tanda hubung "en-dash"
 *   dan nama merek "SIMHP", BUKAN "SIMHPSB"). Assertion di bawah
 *   memakai judul yang SEBENARNYA agar test valid terhadap aplikasi
 *   nyata.
 *
 *   Tidak seperti dugaan umum bahwa "REST API" berarti Laravel
 *   Sanctum, project ini ternyata menggunakan **tymon/jwt-auth**
 *   (JWT klasik) di routes/api.php — endpoint login sesungguhnya
 *   adalah POST /api/auth/login, mengembalikan {message, user, token}
 *   persis seperti disebut di TC-API-003.
 * =====================================================================
 */

test.describe('TC-API — Halaman Publik (tanpa autentikasi)', () => {
  test('TC-API-001 — GET /intro mengembalikan HTML lengkap dengan gsap.min.js & three.min.js', async ({
    request,
  }) => {
    const response = await request.get('/intro');
    expect(response.status()).toBe(200);

    const body = await response.text();
    expect(body).toContain('gsap.min.js');
    expect(body).toContain('three.min.js');
  });

  test('TC-API-002 — GET /login mengembalikan halaman Login dengan form email & password', async ({ request }) => {
    const response = await request.get('/login');
    expect(response.status()).toBe(200);

    const body = await response.text();
    // Judul aktual berbeda dari dokumentasi — lihat catatan di atas.
    expect(body).toContain('Login – SIMHP');
    expect(body).toContain('id="identifier"');
    expect(body).toContain('id="password"');
  });
});

test.describe('TC-API — Proses Login (REST API via JWT)', () => {
  test('TC-API-003 — POST /api/auth/login dengan kredensial valid mengembalikan message, user.role, dan token', async ({
    request,
  }) => {
    const response = await request.post('/api/auth/login', {
      data: { email: USERS.admin.identifier, password: USERS.admin.password },
    });
    expect(response.status()).toBe(200);

    const body = await response.json();
    expect(body.message).toBe('Login successful');
    expect(body.user.role).toBe('admin');
    expect(typeof body.token).toBe('string');
    expect(body.token.length).toBeGreaterThan(10);
  });

  test('(tambahan) POST /api/auth/login dengan kredensial salah ditolak dengan 401', async ({ request }) => {
    const response = await request.post('/api/auth/login', {
      data: { email: USERS.admin.identifier, password: 'password-salah-total' },
    });
    expect(response.status()).toBe(401);

    const body = await response.json();
    expect(body.error).toBe('Invalid credentials');
  });

  test('(tambahan) GET /api/auth/me tanpa token ditolak dengan 401', async ({ request }) => {
    const response = await request.get('/api/auth/me');
    expect(response.status()).toBe(401);
  });

  test('(tambahan) GET /api/auth/me dengan token valid mengembalikan data user yang sedang login', async ({
    request,
  }) => {
    const loginResponse = await request.post('/api/auth/login', {
      data: { email: USERS.admin.identifier, password: USERS.admin.password },
    });
    const { token } = await loginResponse.json();

    const meResponse = await request.get('/api/auth/me', {
      headers: { Authorization: `Bearer ${token}` },
    });
    expect(meResponse.status()).toBe(200);

    const me = await meResponse.json();
    expect(me.email).toBe(USERS.admin.identifier);
  });

  test('(tambahan) endpoint API terproteksi (GET /api/petani) menolak request tanpa Bearer token', async ({
    request,
  }) => {
    const response = await request.get('/api/petani');
    expect(response.status()).toBe(401);
  });

  test('(tambahan) endpoint API terproteksi (GET /api/petani) berhasil diakses dengan token valid', async ({
    request,
  }) => {
    const loginResponse = await request.post('/api/auth/login', {
      data: { email: USERS.admin.identifier, password: USERS.admin.password },
    });
    const { token } = await loginResponse.json();

    const response = await request.get('/api/petani', {
      headers: { Authorization: `Bearer ${token}` },
    });
    expect(response.status()).toBe(200);
  });
});

test.describe('TC-API — Akses Modul Admin tanpa Sesi (Web, harus redirect ke Login)', () => {
  const protectedPaths: Array<[string, string]> = [
    ['TC-API-004', '/admin/dashboard'],
    ['TC-API-005', '/admin/alert'],
    ['TC-API-006', '/admin/laporan'],
    ['TC-API-007', '/admin/stok'],
    ['TC-API-008', '/admin/pengguna'],
    ['TC-API-009', '/admin/pengguna/create'],
    ['TC-API-010', '/admin/petani'],
  ];

  for (const [tcId, path] of protectedPaths) {
    test(`${tcId} — GET ${path} tanpa sesi dialihkan ke halaman Login, tanpa kebocoran data`, async ({ page }) => {
      const response = await page.goto(path);
      await expect(page).toHaveURL(/\/login$/);
      const title = await page.title();
      expect(title).toContain('Login');

      // Tidak ada kebocoran elemen sidebar/menu admin di halaman hasil redirect.
      await expect(page.locator('#sidebar')).toHaveCount(0);
    });
  }
});
