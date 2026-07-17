import { test, expect } from '../fixtures/auth';
import { AlertPage } from '../pages/AlertPage';

/**
 * =====================================================================
 * ALERT STOK & DISTRIBUSI — Test Suite
 * Sumber dokumentasi manual: "TC_Alert_Stok_Distribusi.xlsx" &
 *   test-case-alert-stok-distribusi.md
 * Sumber kebenaran teknis: resources/views/admin/alert/index.blade.php,
 *   app/Http/Controllers/Admin/AlertController.php
 *
 * Modul ini PALING SELARAS dengan dokumentasi dibanding modul lain.
 * Beberapa perilaku penting yang terverifikasi dari kode sumber:
 *   1. Alert dibuat OTOMATIS oleh sistem (bukan diinput manual) setiap
 *      kali halaman /admin/alert dimuat, jika stok saat ini < batas
 *      minimum DAN belum ada alert aktif/dalam_penanganan untuk
 *      komoditas yang sama (checkAndCreateAlert()).
 *   2. Transisi status "Selesai" DIBLOKIR di server jika stok saat ini
 *      masih di bawah `batas_minimum` YANG TERSIMPAN PADA alert
 *      tersebut (bukan dibaca ulang dari konfigurasi terbaru).
 *      Ditampilkan lewat modal dinamis #warningModalJS.
 *   3. Tombol "Tandai Ditangani" & "Selesai" memicu window.confirm()
 *      SEBELUM mengirim request AJAX PATCH.
 *   4. Update berhasil ditampilkan lewat banner sukses yang dibuat
 *      secara dinamis (otomatis hilang setelah ~3 detik) — bukan
 *      lewat reload halaman.
 * =====================================================================
 */

test.describe('Alert - UI & Ringkasan', () => {
  test('TC-AL-UI-001 — kartu status (Aktif/Dalam Penanganan/Selesai) tampil dengan angka', async ({ adminPage }) => {
    const alertPage = new AlertPage(adminPage);
    await alertPage.goto();

    await expect(alertPage.countAktif).toBeVisible();
    await expect(alertPage.countProses).toBeVisible();
    await expect(alertPage.countSelesai).toBeVisible();
  });

  test('TC-AL-UI-002 — tabel riwayat alert menampilkan kolom sesuai dokumentasi', async ({ adminPage }) => {
    const alertPage = new AlertPage(adminPage);
    await alertPage.goto();

    const headers = alertPage.table.locator('thead th');
    await expect(headers).toContainText(['Waktu', 'Komoditas', 'Status']);
  });
});

test.describe('Alert - Konfigurasi Batas Minimum', () => {
  test('TC-AL-CONF-001 — admin berhasil mengubah batas minimum stok', async ({ adminPage }) => {
    const alertPage = new AlertPage(adminPage);
    await alertPage.goto();
    await alertPage.bukaKonfigurasi();
    await alertPage.setBatasMinimum('450', '1100');
    await alertPage.simpanKonfigurasiButton.click();

    await adminPage.waitForURL(/\/admin\/alert/);
    await expect(alertPage.successModal.locator('.modal-message')).toContainText(
      'Konfigurasi alert berhasil disimpan'
    );
  });

  test('TC-AL-CONF-002 — nilai batas minimum negatif ditolak validasi native (min="0")', async ({ adminPage }) => {
    const alertPage = new AlertPage(adminPage);
    await alertPage.goto();
    await alertPage.bukaKonfigurasi();
    await alertPage.batasMinBerasInput.fill('-10');

    const isValid = await alertPage.batasMinBerasInput.evaluate((el: HTMLInputElement) => el.checkValidity());
    expect(isValid).toBe(false);
  });
});

test.describe('Alert - Alur Status (Aktif → Dalam Penanganan → Selesai)', () => {
  test('TC-AL-FLOW-001 — alert baru otomatis terbentuk saat batas minimum dinaikkan jauh di atas stok saat ini', async ({
    adminPage,
  }) => {
    // Menaikkan batas minimum Beras jauh di atas stok riil memaksa
    // sistem membuat alert "Aktif" baru untuk Beras pada reload
    // berikutnya (checkAndCreateAlert). Ini adalah cara yang andal
    // dan deterministik untuk menjamin ada data alert untuk diuji,
    // tanpa bergantung pada state database yang tidak pasti.
    const alertPage = new AlertPage(adminPage);
    await alertPage.goto();
    await alertPage.bukaKonfigurasi();
    await alertPage.setBatasMinimum('999999999', '1000');
    await alertPage.simpanKonfigurasiButton.click();
    await adminPage.waitForURL(/\/admin\/alert/);

    // Reload untuk memicu checkAndCreateAlert() di method index().
    await alertPage.goto();

    const row = alertPage.rowByKomoditasAndStatus('Beras', 'aktif').first();
    await expect(row).toBeVisible({ timeout: 10000 });
  });

  test('TC-AL-FLOW-002 — "Tandai Ditangani" mengubah status Aktif → Dalam Penanganan tanpa reload', async ({
    adminPage,
  }) => {
    const alertPage = new AlertPage(adminPage);

    // Setup: pastikan ada alert Beras berstatus aktif (lihat TC-AL-FLOW-001).
    await alertPage.goto();
    await alertPage.bukaKonfigurasi();
    await alertPage.setBatasMinimum('999999999', '1000');
    await alertPage.simpanKonfigurasiButton.click();
    await adminPage.waitForURL(/\/admin\/alert/);
    await alertPage.goto();

    const row = alertPage.rowByKomoditasAndStatus('Beras', 'aktif').first();
    await expect(row).toBeVisible({ timeout: 10000 });

    adminPage.on('dialog', (dialog) => dialog.accept());
    await alertPage.tandaiDitangani(row);

    await expect(adminPage.locator('.alert-banner.success')).toBeVisible({ timeout: 5000 });
    await expect(alertPage.rowByKomoditasAndStatus('Beras', 'dalam_penanganan').first()).toBeVisible();
  });

  test('TC-AL-FLOW-003 — "Selesai" DIBLOKIR selama stok masih di bawah batas minimum alert (modal peringatan tampil)', async ({
    adminPage,
  }) => {
    const alertPage = new AlertPage(adminPage);

    // Setup: bawa alert Beras ke status "Dalam Penanganan" dengan
    // batas_minimum yang sangat tinggi (mustahil terpenuhi oleh stok riil).
    await alertPage.goto();
    await alertPage.bukaKonfigurasi();
    await alertPage.setBatasMinimum('999999999', '1000');
    await alertPage.simpanKonfigurasiButton.click();
    await adminPage.waitForURL(/\/admin\/alert/);
    await alertPage.goto();

    let row = alertPage.rowByKomoditasAndStatus('Beras', 'aktif').first();
    if (await row.count()) {
      adminPage.on('dialog', (dialog) => dialog.accept());
      await alertPage.tandaiDitangani(row);
      await adminPage.waitForTimeout(500);
    }

    row = alertPage.rowByKomoditasAndStatus('Beras', 'dalam_penanganan').first();
    await expect(row).toBeVisible({ timeout: 10000 });

    await alertPage.tandaiSelesai(row);

    await expect(alertPage.warningModal).toHaveClass(/open/, { timeout: 5000 });
    await expect(alertPage.warningModalMessage).toContainText('di bawah batas minimum');
    // Status TIDAK berubah menjadi selesai.
    await expect(alertPage.rowByKomoditasAndStatus('Beras', 'dalam_penanganan').first()).toBeVisible();
  });
});

test.describe('Alert - Filter Status', () => {
  test('TC-AL-FILTER-001 — filter status "Aktif" hanya menampilkan alert berstatus aktif', async ({ adminPage }) => {
    const alertPage = new AlertPage(adminPage);
    await alertPage.goto();
    await alertPage.filterByStatus('aktif');

    await expect(adminPage).toHaveURL(/status=aktif/);
    const count = await alertPage.alertRows.count();
    if (count > 0) {
      for (const row of await alertPage.alertRows.all()) {
        await expect(row).toHaveAttribute('data-status', 'aktif');
      }
    }
  });
});

test.describe('Alert - Role-based Access', () => {
  test('petugas BISA mengakses & mengelola Alert (role admin & petugas diizinkan)', async ({ petugasPage }) => {
    const response = await petugasPage.goto('/admin/alert');
    expect(response?.status()).not.toBe(403);
  });

  test('petani TIDAK bisa mengakses Alert Stok — HTTP 403', async ({ petaniPage }) => {
    const response = await petaniPage.goto('/admin/alert');
    expect(response?.status()).toBe(403);
  });
});
