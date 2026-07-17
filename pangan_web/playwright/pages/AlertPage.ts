import { type Page, type Locator } from '@playwright/test';

/**
 * AlertPage
 * ------------------------------------------------------------------
 * Selector diambil dari resources/views/admin/alert/index.blade.php.
 * Modul ini adalah yang PALING SELARAS dengan
 * "TC_Alert_Stok_Distribusi.xlsx" dibanding modul lain — struktur
 * tabel (Waktu, Komoditas, Stok Saat Alert, Batas Minimum, Status,
 * Ditangani Oleh, Aksi) dan alur status (Aktif → Dalam Penanganan →
 * Sudah Ditangani) sama persis dengan dokumentasi.
 * ------------------------------------------------------------------
 */
export class AlertPage {
  readonly page: Page;

  readonly ubahKonfigurasiButton: Locator;
  readonly modalKonfigurasi: Locator;
  readonly batasMinBerasInput: Locator;
  readonly batasMinGabahInput: Locator;
  readonly simpanKonfigurasiButton: Locator;

  readonly countAktif: Locator;
  readonly countProses: Locator;
  readonly countSelesai: Locator;

  readonly filterStatus: Locator;
  readonly table: Locator;
  readonly alertRows: Locator;

  readonly successModal: Locator;
  readonly warningModal: Locator;
  readonly warningModalMessage: Locator;
  readonly errorBanner: Locator;

  constructor(page: Page) {
    this.page = page;
    this.ubahKonfigurasiButton = page.getByRole('button', { name: 'Ubah' });
    this.modalKonfigurasi = page.locator('#modalKonfigAlert');
    this.batasMinBerasInput = page.locator('input[name="batas_min_beras"]');
    this.batasMinGabahInput = page.locator('input[name="batas_min_gabah"]');
    this.simpanKonfigurasiButton = this.modalKonfigurasi.getByRole('button', { name: 'Simpan Konfigurasi' });

    this.countAktif = page.locator('#count-aktif');
    this.countProses = page.locator('#count-proses');
    this.countSelesai = page.locator('#count-selesai');

    this.filterStatus = page.locator('#filterStatus');
    this.table = page.locator('#tableAlert');
    this.alertRows = page.locator('tr.alert-row');

    this.successModal = page.locator('#successModal');
    // Modal ini dibuat secara dinamis oleh JS (showWarningModal()) HANYA
    // ketika tombol "Selesai" ditolak karena stok masih di bawah batas
    // minimum yang tersimpan pada alert tsb. Berbeda dari #warningModal
    // (server-rendered, untuk session('warning') biasa).
    this.warningModal = page.locator('#warningModalJS');
    this.warningModalMessage = page.locator('#warningModalMsg');
    this.errorBanner = page.locator('.alert-banner.danger');
  }

  async goto() {
    await this.page.goto('/admin/alert');
  }

  async bukaKonfigurasi() {
    await this.ubahKonfigurasiButton.click();
    await this.modalKonfigurasi.waitFor({ state: 'visible' });
  }

  async setBatasMinimum(batasBeras: string, batasGabah: string) {
    await this.batasMinBerasInput.fill(batasBeras);
    await this.batasMinGabahInput.fill(batasGabah);
  }

  rowByKomoditasAndStatus(komoditas: 'Beras' | 'Gabah', status: 'aktif' | 'dalam_penanganan' | 'selesai'): Locator {
    return this.page.locator(`tr.alert-row[data-status="${status}"]`).filter({ hasText: komoditas });
  }

  /**
   * PENTING: tombol "Tandai Ditangani" memicu `window.confirm()`
   * SEBELUM mengirim request AJAX (PATCH). Pemanggil WAJIB memasang
   * `page.on('dialog', d => d.accept())` sebelum memanggil method
   * ini, jika tidak test akan hang menunggu dialog browser.
   * Setelah sukses, DOM di-update secara live (tanpa reload) oleh
   * fungsi postUpdateAlert() di sisi klien.
   */
  async tandaiDitangani(row: Locator) {
    await row.getByRole('button', { name: 'Tandai Ditangani' }).click();
  }

  /** Sama seperti tandaiDitangani(): memicu window.confirm() dahulu. */
  async tandaiSelesai(row: Locator) {
    await row.getByRole('button', { name: 'Selesai' }).click();
  }

  async filterByStatus(status: '' | 'aktif' | 'dalam_penanganan' | 'selesai') {
    await this.filterStatus.selectOption(status);
  }
}
