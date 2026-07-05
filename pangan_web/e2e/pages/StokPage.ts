/**
 * StokPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan admin/stok/index.blade.php + edit.blade.php.
 *
 * Modal #modalTransaksi punya logika kondisional yang cukup rumit
 * (lihat fungsi onKomoditasChange() & toggleTujuan() di source):
 *  - Komoditas "Gabah" TIDAK BISA jenis "Masuk" (opsi disembunyikan,
 *    otomatis dialihkan ke "Keluar") — karena gabah masuk dicatat lewat
 *    modul Panen, bukan di sini.
 *  - #tujuanGroup (pilih tujuan distribusi) hanya wajib & tampil saat
 *    jenis=keluar DAN komoditas=Beras.
 *  - #fotoBuktiGroup tampil & wajib untuk jenis manapun begitu jenis
 *    dipilih (baik masuk maupun keluar).
 *  - Field "keterangan" punya DUA representasi berbeda dengan `name`
 *    yang sama: input teks bebas (#keteranganText) untuk kasus umum,
 *    atau dropdown pilih petani (#keteranganPetani) khusus saat
 *    jenis=masuk & komoditas=Gabah.
 */
import { type Page, type Locator, expect } from '@playwright/test';
import { BaseAdminPage } from './BaseAdminPage';

export class StokPage extends BaseAdminPage {
  readonly statBeras: Locator;
  readonly statGabah: Locator;
  readonly searchInput: Locator;
  readonly filterJenis: Locator;
  readonly filterKomoditas: Locator;
  readonly filterTanggal: Locator;
  readonly tambahButton: Locator;
  readonly table: Locator;

  // Modal transaksi
  readonly jenisSelect: Locator;
  readonly komoditasSelect: Locator;
  readonly jumlahInput: Locator;
  readonly tanggalInput: Locator;
  readonly tujuanGroup: Locator;
  readonly tujuanSelect: Locator;
  readonly keteranganText: Locator;
  readonly keteranganPetaniSelect: Locator;
  readonly catatanTextarea: Locator;
  readonly fotoBuktiGroup: Locator;
  readonly fotoBuktiInput: Locator;
  readonly submitTransaksiButton: Locator;

  constructor(page: Page) {
    super(page);
    this.statBeras = page.locator('#statStokBerasPage');
    this.statGabah = page.locator('#statStokGabahPage');
    this.searchInput = page.locator('#searchStok');
    this.filterJenis = page.locator('#filterJenis');
    this.filterKomoditas = page.locator('#filterKomoditas');
    this.filterTanggal = page.locator('#filterTanggal');
    this.tambahButton = page.getByRole('button', { name: /Catat Transaksi/i });
    this.table = page.locator('#tableStok');

    const modal = page.locator('#modalTransaksi');
    this.jenisSelect = modal.locator('#jenisTransaksi');
    this.komoditasSelect = modal.locator('#komoditasTransaksi');
    this.jumlahInput = modal.locator('input[name="jumlah"]');
    this.tanggalInput = modal.locator('#tanggalTransaksi');
    this.tujuanGroup = modal.locator('#tujuanGroup');
    this.tujuanSelect = modal.locator('#tujuanSelect');
    this.keteranganText = modal.locator('#keteranganText');
    this.keteranganPetaniSelect = modal.locator('#keteranganPetani');
    this.catatanTextarea = modal.locator('textarea[name="catatan"]');
    this.fotoBuktiGroup = modal.locator('#fotoBuktiGroup');
    this.fotoBuktiInput = modal.locator('#fotoBuktiInput');
    this.submitTransaksiButton = modal.locator('button[type="submit"]');
  }

  async goto() {
    await this.page.goto('/admin/stok');
  }

  async openTambahModal() {
    await this.tambahButton.click();
    await this.expectModalOpen('modalTransaksi');
  }

  async selectJenis(jenis: 'masuk' | 'keluar') {
    await this.jenisSelect.selectOption(jenis);
  }

  async selectKomoditas(komoditas: 'Gabah' | 'Beras') {
    await this.komoditasSelect.selectOption(komoditas);
  }

  rowById(id: string | number): Locator {
    return this.page.locator(`#stokRow-${id}`);
  }

  async toggleRowStatus(id: string | number) {
    await this.rowById(id).locator('button[title="Batalkan transaksi"], button[title="Aktifkan kembali"]').click();
  }

  async gotoEdit(id: string | number) {
    await this.page.goto(`/admin/stok/${id}/edit`);
  }
}
