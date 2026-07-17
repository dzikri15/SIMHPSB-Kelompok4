import { type Page, type Locator } from '@playwright/test';

/**
 * HargaPage
 * ------------------------------------------------------------------
 * Selector diambil dari resources/views/admin/harga/index.blade.php
 * dan resources/views/admin/harga/form.blade.php.
 *
 * CATATAN PENTING (lihat README.md bagian "Temuan Perbedaan"):
 * Modul ini adalah yang PALING BANYAK berubah dibanding
 * "TC_Harga_HPP.xlsx". Field "Ongkos Giling" dan "Rasio Konversi
 * Gabah → Beras" TIDAK ADA lagi di form. Form saat ini hanya berisi:
 * harga_beli_gabah, harga_jual_beras, berlaku_mulai, is_active.
 * Sebagai gantinya, ada "Kalkulator Penghasilan" sisi klien yang
 * menghitung Total = Harga x Berat (bukan konversi gabah->beras).
 * ------------------------------------------------------------------
 */
export class HargaPage {
  readonly page: Page;

  readonly tambahKonfigurasiLink: Locator;
  readonly table: Locator;
  readonly tableRows: Locator;
  readonly successBanner: Locator;
  readonly errorBanner: Locator;

  // Form (create/edit)
  readonly hargaBeliGabahInput: Locator;
  readonly hargaJualBerasInput: Locator;
  readonly berlakuMulaiInput: Locator;
  readonly isActiveCheckbox: Locator;
  readonly simpanKonfigurasiButton: Locator;
  readonly kembaliLink: Locator;

  // Kalkulator sisi-klien
  readonly simulasiJumlahInput: Locator;
  readonly hasilTotalGabah: Locator;
  readonly hasilTotalBeras: Locator;

  constructor(page: Page) {
    this.page = page;
    this.tambahKonfigurasiLink = page.getByRole('link', { name: 'Tambah Konfigurasi' });
    this.table = page.locator('table.data-table');
    this.tableRows = page.locator('table.data-table tbody tr');
    this.successBanner = page.locator('.alert-banner.success');
    this.errorBanner = page.locator('.alert-banner.danger');

    this.hargaBeliGabahInput = page.locator('#harga_beli_gabah');
    this.hargaJualBerasInput = page.locator('#harga_jual_beras');
    this.berlakuMulaiInput = page.locator('input[name="berlaku_mulai"]');
    this.isActiveCheckbox = page.locator('#isActive');
    this.simpanKonfigurasiButton = page.getByRole('button', { name: 'Simpan Konfigurasi' });
    this.kembaliLink = page.getByRole('link', { name: 'Kembali' });

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

  async isiForm(data: { hargaBeliGabah: string; hargaJualBeras: string; berlakuMulai?: string; isActive?: boolean }) {
    await this.hargaBeliGabahInput.fill(data.hargaBeliGabah);
    await this.hargaJualBerasInput.fill(data.hargaJualBeras);
    if (data.berlakuMulai) {
      await this.berlakuMulaiInput.fill(data.berlakuMulai);
    }
    if (data.isActive === false) {
      await this.isActiveCheckbox.uncheck();
    } else if (data.isActive === true) {
      await this.isActiveCheckbox.check();
    }
  }

  async submit() {
    await this.simpanKonfigurasiButton.click();
  }

  rowForTanggal(tanggalDisplay: string): Locator {
    return this.tableRows.filter({ hasText: tanggalDisplay });
  }

  activateButtonForRow(row: Locator): Locator {
    return row.getByTitle('Jadikan Aktif');
  }

  editLinkForRow(row: Locator): Locator {
    return row.getByTitle('Edit');
  }

  deleteButtonForRow(row: Locator): Locator {
    return row.getByTitle('Hapus');
  }
}
