import { type Page, type Locator } from '@playwright/test';

/**
 * StokGudangPage
 * ------------------------------------------------------------------
 * Selector diambil dari resources/views/admin/stok/index.blade.php.
 *
 * Aturan bisnis penting yang terverifikasi dari StokController@store:
 *  - "Gabah" + jenis "masuk" DITOLAK (harus lewat menu Pencatatan
 *    Panen). Pesan error: "Gabah Masuk tidak bisa dicatat manual.
 *    Gunakan menu Pencatatan Panen."
 *  - "Beras" + jenis "masuk" ditolak jika saldo Gabah saat ini <= 0.
 *  - foto_bukti WAJIB untuk transaksi masuk maupun keluar (validasi
 *    server: required|image|mimes:jpeg,jpg,png,webp|max:2048).
 *  - Field "Tujuan Distribusi" hanya muncul & wajib untuk kombinasi
 *    jenis=keluar & komoditas=Beras.
 * ------------------------------------------------------------------
 */
export class StokGudangPage {
  readonly page: Page;

  // Kartu ringkasan (8 kartu)
  readonly saldoBeras: Locator;
  readonly saldoGabah: Locator;

  // Toolbar
  readonly searchInput: Locator;
  readonly filterJenis: Locator;
  readonly filterKomoditas: Locator;
  readonly filterTanggal: Locator;
  readonly catatTransaksiButton: Locator;

  readonly errorBanner: Locator;
  readonly successBanner: Locator;
  readonly table: Locator;
  readonly tableRows: Locator;

  // Modal "Catat Transaksi Stok"
  readonly modal: Locator;
  readonly jenisSelect: Locator;
  readonly komoditasSelect: Locator;
  readonly jumlahInput: Locator;
  readonly tanggalInput: Locator;
  readonly tujuanSelect: Locator;
  readonly keteranganTextInput: Locator;
  readonly catatanTextarea: Locator;
  readonly fotoBuktiInput: Locator;
  readonly simpanButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.saldoBeras = page.locator('#statStokBerasPage');
    this.saldoGabah = page.locator('#statStokGabahPage');

    this.searchInput = page.locator('#searchStok');
    this.filterJenis = page.locator('#filterJenis');
    this.filterKomoditas = page.locator('#filterKomoditas');
    this.filterTanggal = page.locator('#filterTanggal');
    this.catatTransaksiButton = page.getByRole('button', { name: 'Catat Transaksi' });

    this.errorBanner = page.locator('.alert-banner.danger');
    this.successBanner = page.locator('.alert-banner.success');
    this.table = page.locator('#tableStok');
    this.tableRows = page.locator('#tableStok tbody tr');

    this.modal = page.locator('.modal', { hasText: 'Catat Transaksi Stok' });
    this.jenisSelect = page.locator('#jenisTransaksi');
    this.komoditasSelect = page.locator('#komoditasTransaksi');
    this.jumlahInput = page.locator('input[name="jumlah"]');
    this.tanggalInput = page.locator('#tanggalTransaksi');
    this.tujuanSelect = page.locator('#tujuanSelect');
    this.keteranganTextInput = page.locator('#keteranganText');
    this.catatanTextarea = page.locator('textarea[name="catatan"]');
    this.fotoBuktiInput = page.locator('#fotoBuktiInput');
    this.simpanButton = this.modal.getByRole('button', { name: 'Simpan' });
  }

  async goto() {
    await this.page.goto('/admin/stok');
  }

  async openModal() {
    await this.catatTransaksiButton.click();
    await this.modal.waitFor({ state: 'visible' });
  }

  async isiFormTransaksi(data: {
    jenis: 'masuk' | 'keluar';
    komoditas: 'Gabah' | 'Beras';
    jumlah: string;
    tanggal?: string; // yyyy-mm-ddThh:mm
    tujuanDistribusi?: string;
    keterangan?: string;
    catatan?: string;
    fotoPath?: string;
  }) {
    await this.jenisSelect.selectOption(data.jenis);
    await this.komoditasSelect.selectOption(data.komoditas);
    await this.jumlahInput.fill(data.jumlah);
    if (data.tanggal) {
      await this.tanggalInput.fill(data.tanggal);
    }
    if (data.jenis === 'keluar' && data.komoditas === 'Beras' && data.tujuanDistribusi) {
      await this.tujuanSelect.selectOption(data.tujuanDistribusi);
    }
    if (data.keterangan) {
      await this.keteranganTextInput.fill(data.keterangan);
    }
    if (data.catatan) {
      await this.catatanTextarea.fill(data.catatan);
    }
    if (data.fotoPath) {
      await this.fotoBuktiInput.setInputFiles(data.fotoPath);
    }
  }

  async submit() {
    await this.simpanButton.click();
  }

  async filterByJenis(jenis: '' | 'masuk' | 'keluar') {
    await this.filterJenis.selectOption(jenis);
  }

  async filterByKomoditas(komoditas: '' | 'beras' | 'gabah') {
    await this.filterKomoditas.selectOption(komoditas);
  }

  async search(query: string) {
    await this.searchInput.fill(query);
  }
}
