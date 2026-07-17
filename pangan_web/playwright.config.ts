import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright config untuk project SIMHP(SB).
 * Referensi resmi: https://playwright.dev/docs/test-configuration
 *
 * CATATAN PENTING soal `fullyParallel: false` & `workers: 1`:
 * Beberapa modul (Stok Gudang, Alert) berbagi STATE GLOBAL di
 * database — misalnya saldo stok berjalan (running balance) dan
 * satu baris konfigurasi AlertConfiguration. Jika test-test yang
 * saling memengaruhi state ini dijalankan PARALEL, hasilnya bisa
 * flaky/tidak konsisten (mis. dua test sama-sama mengubah batas
 * minimum alert di waktu bersamaan). Karena itu, secara default
 * suite ini dijalankan SEKUENSIAL demi keandalan hasil (cocok
 * untuk kebutuhan akademik/demo). Jika Anda merefactor test agar
 * benar-benar independen (mis. tiap test pakai data unik & tidak
 * bergantung pada saldo bersama), silakan aktifkan kembali
 * `fullyParallel: true` untuk mempercepat eksekusi.
 */
export default defineConfig({
  testDir: './playwright',

  fullyParallel: false,
  workers: 1,

  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,

  reporter: [['html', { open: 'never' }], ['list']],

  timeout: 30_000,
  expect: {
    timeout: 8_000,
  },

  use: {
    /* Sesuaikan dengan APP_URL di .env Laravel Anda. Bisa dioverride
       lewat environment variable BASE_URL, mis:
       BASE_URL=http://127.0.0.1:8000 npx playwright test */
    baseURL: process.env.BASE_URL || 'http://localhost:8000',

    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },

    // Aktifkan browser lain bila diperlukan untuk cross-browser testing:
    // {
    //   name: 'firefox',
    //   use: { ...devices['Desktop Firefox'] },
    // },
    // {
    //   name: 'webkit',
    //   use: { ...devices['Desktop Safari'] },
    // },
  ],

  /* Jalankan otomatis server Laravel sebelum test dimulai. Aktifkan
     baris di bawah jika ingin Playwright yang menyalakan `php artisan
     serve` secara otomatis (pastikan DB sudah di-migrate & di-seed
     lebih dulu). Dinonaktifkan secara default karena banyak setup
     lokal menjalankan server terpisah (mis. Laravel Herd/Valet/Sail). */
  // webServer: {
  //   command: 'php artisan serve',
  //   url: 'http://localhost:8000',
  //   reuseExistingServer: !process.env.CI,
  //   timeout: 120_000,
  // },
});
