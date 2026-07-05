/**
 * PanenPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan admin/panen/index.blade.php. Berbeda dari halaman
 * lain, form "Catat Hasil Panen Baru" TIDAK berupa modal — selalu
 * tampil langsung di kolom kiri halaman (grid-2).
 *
 * Dropdown petani-nya kustom (bukan <select> asli): klik untuk buka
 * panel, ketik untuk mencari, klik <li> untuk memilih — nilai
 * sesungguhnya disimpan di <input type="hidden" id="petaniIdInput">.
 *
 * Tombol hapus riwayat memakai window.confirm() bawaan browser, BUKAN
 * modal kustom — lihat handler `page.on('dialog', ...)` di spec file.
 */
import { type Page, type Locator, expect } from '@playwright/test';
import { BaseAdminPage } from './BaseAdminPage';

export class PanenPage extends BaseAdminPage {
  readonly petaniDisplay: Locator;
  readonly petaniSearchInput: Locator;
  readonly petaniPanel: Locator;
  readonly petaniHiddenInput: Locator;
  readonly musimSelect: Locator;
  readonly tanggalInput: Locator;
  readonly jumlahGabahInput: Locator;
  readonly komoditasSelect: Locator;
  readonly catatanTextarea: Locator;
  readonly fotoDropZone: Locator;
  readonly fotoInput: Locator;
  readonly submitButton: Locator;
  readonly riwayatTable: Locator;

  constructor(page: Page) {
    super(page);
    this.petaniDisplay = page.locator('#petaniDisplay');
    this.petaniSearchInput = page.locator('#petaniSearch');
    this.petaniPanel = page.locator('#petaniPanel');
    this.petaniHiddenInput = page.locator('#petaniIdInput');
    this.musimSelect = page.locator('select[name="musim"]');
    this.tanggalInput = page.locator('input[name="tanggal_panen"]');
    this.jumlahGabahInput = page.locator('#jumlahGabah');
    this.komoditasSelect = page.locator('select[name="komoditas"]');
    this.catatanTextarea = page.locator('textarea[name="catatan"]');
    this.fotoDropZone = page.locator('#foto-drop-zone');
    this.fotoInput = page.locator('#foto_bukti_input');
    this.submitButton = page.getByRole('button', { name: /Simpan Catatan Panen/i });
    this.riwayatTable = page.locator('.card', { hasText: 'Riwayat Panen Terbaru' }).locator('table');
  }

  async goto() {
    await this.page.goto('/admin/panen');
  }

  async choosePetaniByName(nama: string) {
    await this.petaniDisplay.click();
    await expect(this.petaniPanel).toBeVisible();
    await this.petaniSearchInput.fill(nama);
    await this.page.locator(`#petaniList .petani-opt`, { hasText: nama }).first().click();
  }

  /**
   * Setelah dipilih, #petaniDisplayText berisi "Nama – luas m²" (lihat
   * fungsi selectPetani() di source), jadi kita cek dengan toContainText,
   * bukan toHaveText (exact match) yang pasti gagal.
   */
  async expectPetaniSelected(nama: string) {
    await expect(this.page.locator('#petaniDisplayText')).toContainText(nama);
    await expect(this.petaniHiddenInput).not.toHaveValue('');
  }

  async fillForm(opts: {
    musim: 'Kemarau' | 'Hujan';
    tanggal?: string;
    jumlahGabah: string;
    catatan?: string;
    fotoPath: string;
  }) {
    await this.musimSelect.selectOption(opts.musim);
    if (opts.tanggal) await this.tanggalInput.fill(opts.tanggal);
    await this.jumlahGabahInput.fill(opts.jumlahGabah);
    if (opts.catatan) await this.catatanTextarea.fill(opts.catatan);
    await this.fotoInput.setInputFiles(opts.fotoPath);
  }

  async submit() {
    await this.submitButton.click();
  }

  rowByPetaniName(nama: string): Locator {
    return this.riwayatTable.locator('tr.panen-row').filter({ hasText: nama });
  }

  /**
   * Menghapus baris riwayat panen. Karena konfirmasinya native `confirm()`,
   * kita harus pasang listener dialog SEBELUM men-trigger klik tombol.
   * Memakai .first() karena satu petani bisa punya beberapa baris riwayat.
   */
  async deleteRow(nama: string, accept: boolean) {
    this.page.once('dialog', (dialog) => {
      if (accept) dialog.accept();
      else dialog.dismiss();
    });
    await this.rowByPetaniName(nama).first().getByRole('button', { name: /Hapus/i }).click();
  }
}
