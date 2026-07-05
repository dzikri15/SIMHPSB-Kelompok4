/**
 * HargaPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan admin/harga/index.blade.php dan admin/harga/form.blade.php
 * (form.blade.php dipakai untuk create MAUPUN edit).
 *
 * Input harga memakai format ribuan Indonesia secara live (mis. "13.500")
 * lewat JS formatCurrency(), dan dinormalisasi kembali ke angka polos
 * sebelum submit lewat normalizeCurrencyInputs(). Untuk mengisi field ini
 * di test, cukup ketik angka polos — server tetap menerimanya karena
 * validasinya `numeric`.
 */
import { type Page, type Locator, expect } from '@playwright/test';
import { BaseAdminPage } from './BaseAdminPage';

export class HargaPage extends BaseAdminPage {
  readonly tambahLink: Locator;
  readonly table: Locator;

  // Form create/edit
  readonly hargaBeliInput: Locator;
  readonly hargaJualInput: Locator;
  readonly berlakuMulaiInput: Locator;
  readonly isActiveCheckbox: Locator;
  readonly submitButton: Locator;

  // Kalkulator simulasi
  readonly simulasiJumlahInput: Locator;
  readonly hasilTotalGabah: Locator;
  readonly hasilTotalBeras: Locator;

  constructor(page: Page) {
    super(page);
    this.tambahLink = page.getByRole('link', { name: /Tambah Konfigurasi/i });
    this.table = page.locator('table.data-table');

    this.hargaBeliInput = page.locator('#harga_beli_gabah');
    this.hargaJualInput = page.locator('#harga_jual_beras');
    this.berlakuMulaiInput = page.locator('input[name="berlaku_mulai"]');
    this.isActiveCheckbox = page.locator('#isActive');
    this.submitButton = page.getByRole('button', { name: /Simpan Konfigurasi/i });

    this.simulasiJumlahInput = page.locator('#simulasi_jumlah');
    this.hasilTotalGabah = page.locator('#hasil_total_gabah');
    this.hasilTotalBeras = page.locator('#hasil_total_beras');
  }

  async goto() {
    await this.page.goto('/admin/harga');
  }

  async gotoCreate() {
    await this.page.goto('/admin/harga/create');
  }

  async fillForm(opts: { hargaBeli: string; hargaJual: string; berlakuMulai?: string; aktif?: boolean }) {
    await this.hargaBeliInput.fill(opts.hargaBeli);
    await this.hargaJualInput.fill(opts.hargaJual);
    if (opts.berlakuMulai) await this.berlakuMulaiInput.fill(opts.berlakuMulai);
    const isChecked = await this.isActiveCheckbox.isChecked();
    if (opts.aktif !== undefined && opts.aktif !== isChecked) {
      await this.isActiveCheckbox.click();
    }
  }

  async submit() {
    await this.submitButton.click();
  }

  rowByTanggal(tanggalText: string): Locator {
    return this.table.locator('tbody tr').filter({ hasText: tanggalText });
  }

  async activate(rowLocator: Locator) {
    await rowLocator.locator('button[title="Jadikan Aktif"]').click();
  }

  async delete(rowLocator: Locator, accept: boolean) {
    this.page.once('dialog', (dialog) => (accept ? dialog.accept() : dialog.dismiss()));
    await rowLocator.locator('button[title="Hapus"]').click();
  }
}
