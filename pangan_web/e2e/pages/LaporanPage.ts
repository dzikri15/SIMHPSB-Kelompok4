/**
 * LaporanPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan admin/laporan/index.blade.php. Sebagian besar filter
 * (komoditas, petani_id) langsung men-submit form GET begitu nilainya
 * berubah (onchange="...submit()"), sehingga hasil laporan berubah tanpa
 * perlu tombol submit terpisah.
 */
import { type Page, type Locator, expect } from '@playwright/test';
import { BaseAdminPage } from './BaseAdminPage';

export class LaporanPage extends BaseAdminPage {
  readonly jenisSelect: Locator;
  readonly komoditasSelect: Locator;
  readonly petaniSelect: Locator;
  readonly komoditasWrapper: Locator;
  readonly petaniWrapper: Locator;
  readonly dariInput: Locator;
  readonly sampaiInput: Locator;
  readonly exportPdfLink: Locator;
  readonly exportExcelLink: Locator;
  readonly chart: Locator;

  constructor(page: Page) {
    super(page);
    this.jenisSelect = page.locator('#jenisLaporan');
    this.komoditasSelect = page.locator('#komoditas');
    this.petaniSelect = page.locator('#petani_id');
    this.komoditasWrapper = page.locator('#komoditasFilterWrapper');
    this.petaniWrapper = page.locator('#petaniFilterWrapper');
    this.dariInput = page.locator('input[name="dari"]');
    this.sampaiInput = page.locator('input[name="sampai"]');
    this.exportPdfLink = page.getByRole('link', { name: /PDF/i });
    this.exportExcelLink = page.getByRole('link', { name: /Excel/i });
    this.chart = page.locator('#chartLaporan');
  }

  async goto() {
    await this.page.goto('/admin/laporan');
  }

  /** Mengubah jenis laporan mengubah tampilan filter (toggle komoditas/petani) LALU men-submit form. */
  async selectJenis(jenis: 'stok' | 'panen') {
    await Promise.all([this.page.waitForNavigation(), this.jenisSelect.selectOption(jenis)]);
  }

  /** Memilih komoditas akan men-submit ulang form (reload halaman penuh), jadi kita tunggu navigasinya selesai. */
  async selectKomoditas(value: string) {
    await Promise.all([this.page.waitForNavigation(), this.komoditasSelect.selectOption(value)]);
  }

  async setRange(dari: string, sampai: string) {
    await this.dariInput.fill(dari);
    await this.sampaiInput.fill(sampai);
  }
}
