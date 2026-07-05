/**
 * AlertPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan admin/alert/index.blade.php.
 *
 * "Tandai Ditangani" dan "Tandai Selesai" memakai window.confirm() bawaan
 * browser SEBELUM melakukan fetch() PATCH ke server — jadi test harus
 * memasang listener dialog sebelum mengklik tombolnya.
 */
import { type Page, type Locator, expect } from '@playwright/test';
import { BaseAdminPage } from './BaseAdminPage';

export class AlertPage extends BaseAdminPage {
  readonly konfigurasiButton: Locator;
  readonly filterStatus: Locator;
  readonly table: Locator;
  readonly countAktif: Locator;
  readonly countProses: Locator;
  readonly countSelesai: Locator;

  // Modal konfigurasi
  readonly batasMinBerasInput: Locator;
  readonly batasMinGabahInput: Locator;

  constructor(page: Page) {
    super(page);
    // Tombol untuk membuka modal konfigurasi teksnya cuma "Ubah" — scope ke card
    // "Konfigurasi Batas Minimum" supaya tidak salah pilih tombol "Ubah" lain di halaman.
    this.konfigurasiButton = page
      .locator('.card', { hasText: 'Konfigurasi Batas Minimum' })
      .getByRole('button', { name: /Ubah/i });
    this.filterStatus = page.locator('#filterStatus');
    this.table = page.locator('#tableAlert');
    this.countAktif = page.locator('#count-aktif');
    this.countProses = page.locator('#count-proses');
    this.countSelesai = page.locator('#count-selesai');

    const modal = page.locator('#modalKonfigAlert');
    this.batasMinBerasInput = modal.locator('input[name="batas_min_beras"]');
    this.batasMinGabahInput = modal.locator('input[name="batas_min_gabah"]');
  }

  async goto() {
    await this.page.goto('/admin/alert');
  }

  async openKonfigurasiModal() {
    await this.konfigurasiButton.click();
    await this.expectModalOpen('modalKonfigAlert');
  }

  /** Filter status memuat ulang halaman penuh lewat query string ?status=..., bukan client-side. */
  async filterByStatus(status: '' | 'aktif' | 'dalam_penanganan' | 'selesai') {
    await Promise.all([this.page.waitForNavigation(), this.filterStatus.selectOption(status)]);
  }

  rowById(id: string | number): Locator {
    return this.page.locator(`tr.alert-row[data-id="${id}"]`);
  }

  async firstRowWithStatus(status: 'aktif' | 'dalam_penanganan' | 'selesai'): Promise<Locator> {
    return this.table.locator(`tr.alert-row[data-status="${status}"]`).first();
  }

  async tandaiDitangani(row: Locator, accept = true) {
    this.page.once('dialog', (dialog) => (accept ? dialog.accept() : dialog.dismiss()));
    await row.getByRole('button', { name: /Tandai Ditangani/i }).click();
  }

  async tandaiSelesai(row: Locator, accept = true) {
    this.page.once('dialog', (dialog) => (accept ? dialog.accept() : dialog.dismiss()));
    await row.getByRole('button', { name: /Selesai/i }).click();
  }

  statusBadge(id: string | number): Locator {
    return this.page.locator(`#status-${id}`);
  }

  /**
   * Ditampilkan lewat JS (showWarningModal()) — dibuat & disisipkan ke DOM
   * secara dinamis saat percobaan "Tandai Selesai" gagal karena stok
   * masih di bawah batas minimum. Elemennya baru ADA di DOM setelah
   * gagal sekali; jangan panggil sebelum memicu kegagalan tersebut.
   */
  get warningModalJS(): Locator {
    return this.page.locator('#warningModalJS');
  }

  async dismissWarningModalJS() {
    await this.warningModalJS.locator('button', { hasText: 'Mengerti' }).click();
  }
}
