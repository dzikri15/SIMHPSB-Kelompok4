/**
 * TujuanDistribusiPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan admin/tujuan-distribusi/index.blade.php.
 *
 * Berbeda dari halaman lain, konfirmasi hapusnya BUKAN window.confirm()
 * bawaan, melainkan modal kustom (#modalHapusTujuan) yang pesan &
 * action form-nya diisi ulang secara dinamis lewat confirmDelete(id, nama).
 */
import { type Page, type Locator, expect } from '@playwright/test';
import { BaseAdminPage } from './BaseAdminPage';

export class TujuanDistribusiPage extends BaseAdminPage {
  readonly tambahButton: Locator;
  readonly table: Locator;
  readonly namaInputModal: Locator;
  readonly hapusMessage: Locator;

  constructor(page: Page) {
    super(page);
    this.tambahButton = page.getByRole('button', { name: /Tambah Tujuan/i });
    this.table = page.locator('table.data-table');
    this.namaInputModal = page.locator('#modalTambahTujuan input[name="nama"]');
    this.hapusMessage = page.locator('#hapusMsg');
  }

  async goto() {
    await this.page.goto('/admin/tujuan-distribusi');
  }

  async openTambahModal() {
    await this.tambahButton.click();
    await this.expectModalOpen('modalTambahTujuan');
  }

  async submitTambah(nama: string) {
    await this.namaInputModal.fill(nama);
    await this.page.locator('#modalTambahTujuan button[type="submit"]').click();
  }

  rowByNama(nama: string): Locator {
    return this.table.locator('tbody tr').filter({ hasText: nama });
  }

  async openHapusModal(nama: string) {
    await this.rowByNama(nama).getByRole('button', { name: /Hapus/i }).click();
    await this.expectModalOpen('modalHapusTujuan');
    await expect(this.hapusMessage).toContainText(nama);
  }

  async confirmHapus() {
    await this.page.locator('#formHapusTujuan button[type="submit"]').click();
  }
}
