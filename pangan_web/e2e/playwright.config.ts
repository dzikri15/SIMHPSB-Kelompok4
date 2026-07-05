import { defineConfig, devices } from '@playwright/test';

/**
 * Konfigurasi Playwright untuk SIMHPSB.
 *
 * PRASYARAT SEBELUM MENJALANKAN TEST:
 *   1. Server Laravel harus sudah jalan (default: `php artisan serve`
 *      di http://localhost:8000). Set env var BASE_URL bila server
 *      jalan di alamat lain.
 *   2. Database HARUS dalam kondisi ter-seed bersih:
 *        php artisan migrate:fresh --seed
 *      Beberapa test (terutama RBAC & login) bergantung pada akun
 *      bawaan dari DatabaseSeeder (admin@simhpsb.com, petugas@simhpsb.com,
 *      petani@simhpsb.com — lihat playwright/fixtures/test-data.ts).
 *   3. Test suite ini TIDAK mereset database secara otomatis di antara
 *      run. Menjalankannya berkali-kali tanpa reset DB akan menumpuk
 *      data uji (nama & email selalu dibuat unik dengan timestamp agar
 *      aman dari duplikasi, tapi tabel akan terus bertambah).
 *
 * Lihat playwright/README.md untuk penjelasan lebih lengkap.
 */
export default defineConfig({
  testDir: './playwright',

  /* Jalankan test antar file secara paralel */
  fullyParallel: true,
  /* Gagalkan build CI kalau ada .only() yang ketinggalan di source */
  forbidOnly: !!process.env.CI,
  /* Retry otomatis hanya di CI */
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',

  use: {
    baseURL: process.env.BASE_URL || 'http://localhost',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    {
      /* Project khusus untuk login 3 role & menyimpan storageState — lihat auth.setup.ts */
      name: 'setup',
      testMatch: /auth\.setup\.ts/,
    },

    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
      dependencies: ['setup'],
    },

    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
      dependencies: ['setup'],
    },

    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
      dependencies: ['setup'],
    },
  ],

  /* Aktifkan ini kalau ingin Playwright otomatis menjalankan `php artisan serve`. */
  // webServer: {
  //   command: 'php artisan serve',
  //   url: 'http://localhost:8000',
  //   reuseExistingServer: !process.env.CI,
  // },
});
