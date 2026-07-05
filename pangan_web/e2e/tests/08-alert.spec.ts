/**
 * 08-alert.spec.ts
 * ------------------------------------------------------------------
 * Menguji admin/alert/index.blade.php.
 *
 * CATATAN METODOLOGI PENGUJIAN:
 * Transisi status alert bergantung pada data yang SUDAH ADA di database
 * (alert dibuat otomatis oleh sistem lewat AlertController::checkAndCreateAlert
 * setiap kali stok turun di bawah batas minimum — bukan lewat form manual
 * di UI). Karena test ini tidak mengontrol isi database secara langsung,
 * test transisi status ditulis agar ADAPTIF: jika tidak ada baris dengan
 * status yang dibutuhkan saat test dijalankan, test di-skip dengan pesan
 * yang jelas alih-alih dipaksakan dan menghasilkan false failure.
 *
 * Begitu juga untuk "Tandai Selesai": dari AlertController::tangani(),
 * transisi ke status 'selesai' HANYA berhasil jika stok saat ini sudah
 * di atas batas minimum. Karena nilai stok aktual bergantung pada data
 * yang ada, test ini memverifikasi bahwa SALAH SATU dari dua kemungkinan
 * hasil yang valid terjadi (berhasil menjadi "Sudah Ditangani", ATAU
 * ditolak lewat modal peringatan) — bukan memaksakan satu hasil tertentu.
 */
import { test, expect } from '../fixtures/auth.fixtures';
import { AlertPage } from '../pages/AlertPage';

test.describe('Alert Stok — halaman utama', () => {
  test('menampilkan kartu ringkasan dan tabel alert', async ({ adminPage }) => {
    const alert = new AlertPage(adminPage);
    await alert.goto();

    await expect(alert.countAktif).toBeVisible();
    await expect(alert.countProses).toBeVisible();
    await expect(alert.countSelesai).toBeVisible();
    await expect(alert.table).toBeVisible();
  });

  test('filter status memuat ulang halaman dengan query string yang sesuai', async ({ adminPage }) => {
    const alert = new AlertPage(adminPage);
    await alert.goto();

    await alert.filterByStatus('aktif');
    await expect(adminPage).toHaveURL(/[?&]status=aktif/);

    await alert.filterByStatus('selesai');
    await expect(adminPage).toHaveURL(/[?&]status=selesai/);
  });
});

test.describe('Alert Stok — konfigurasi batas minimum', () => {
  test('modal konfigurasi bisa dibuka, diisi, dan disimpan', async ({ adminPage }) => {
    const alert = new AlertPage(adminPage);
    await alert.goto();

    await alert.openKonfigurasiModal();
    await alert.batasMinBerasInput.fill('350');
    await alert.batasMinGabahInput.fill('900');
    await adminPage.locator('#modalKonfigAlert button[type="submit"]').click();

    await expect(adminPage.locator('body')).toContainText(/Konfigurasi alert berhasil disimpan/i);
  });

  test('menolak submit ketika batas minimum dikosongkan (validasi HTML5)', async ({ adminPage }) => {
    const alert = new AlertPage(adminPage);
    await alert.goto();

    await alert.openKonfigurasiModal();
    await alert.batasMinBerasInput.fill('');
    await adminPage.locator('#modalKonfigAlert button[type="submit"]').click();

    // Browser menahan submit karena atribut `required`, modal harus tetap ada di URL yang sama
    await expect(adminPage).toHaveURL(/\/admin\/alert$/);
  });
});

test.describe('Alert Stok — transisi status', () => {
  test('menandai alert aktif menjadi "Dalam Penanganan"', async ({ adminPage }) => {
    const alert = new AlertPage(adminPage);
    await alert.goto();

    const row = alert.table.locator('tr.alert-row[data-status="aktif"]').first();
    if ((await row.count()) === 0) {
      test.skip(true, 'Tidak ada alert berstatus "aktif" saat ini — lewati (lihat catatan metodologi di atas file).');
    }

    const id = await row.getAttribute('data-id');
    await alert.tandaiDitangani(row, true);

    await expect(alert.statusBadge(id!)).toContainText(/Dalam Penanganan/i);
    await expect(row.getByRole('button', { name: /Selesai/i })).toBeVisible();
  });

  test('membatalkan konfirmasi "Tandai Ditangani" tidak mengubah status', async ({ adminPage }) => {
    const alert = new AlertPage(adminPage);
    await alert.goto();

    const row = alert.table.locator('tr.alert-row[data-status="aktif"]').first();
    if ((await row.count()) === 0) {
      test.skip(true, 'Tidak ada alert berstatus "aktif" saat ini — lewati.');
    }

    const id = await row.getAttribute('data-id');
    await alert.tandaiDitangani(row, false); // dialog di-dismiss, bukan accept

    await expect(alert.statusBadge(id!)).toContainText(/Aktif/i);
  });

  test('mencoba "Tandai Selesai" menghasilkan salah satu dari dua kemungkinan valid', async ({ adminPage }) => {
    const alert = new AlertPage(adminPage);
    await alert.goto();

    const row = alert.table.locator('tr.alert-row[data-status="dalam_penanganan"]').first();
    if ((await row.count()) === 0) {
      test.skip(true, 'Tidak ada alert berstatus "dalam_penanganan" saat ini — lewati.');
    }

    const id = await row.getAttribute('data-id');
    await alert.tandaiSelesai(row, true);

    // Beri waktu untuk salah satu dari dua kemungkinan hasil muncul.
    const berhasil = alert.statusBadge(id!).filter({ hasText: /Sudah Ditangani/i });
    const ditolak = alert.warningModalJS;

    await expect(berhasil.or(ditolak)).toBeVisible({ timeout: 5000 });
  });
});
