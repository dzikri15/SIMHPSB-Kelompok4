import { type Page, type Locator } from '@playwright/test';

/**
 * PetaniPage
 * ------------------------------------------------------------------
 * Selector diambil dari resources/views/admin/petani/index.blade.php.
 *
 * CATATAN PENTING (lihat README.md bagian "Temuan Perbedaan"):
 * Form "Tambah Petani" pada kode sumber TIDAK memiliki field NIK
 * seperti pada dokumentasi TC_Petani_Lahan.xlsx. Sebagai gantinya,
 * form ini membuat sepasang data Petani + akun User (email & password)
 * sekaligus, karena field ini yang dipakai petani untuk login.
 *
 * Form "Tambah Petani" dikirim lewat fetch() (AJAX) dengan
 * preventDefault(), BUKAN form POST biasa:
 *  - Sukses (HTTP 2xx)  -> modal tertutup lalu location.reload()
 *  - Gagal (HTTP != 2xx)-> browser native alert() "Gagal menyimpan
 *    data. Silakan coba lagi." (BUKAN pesan validasi per-field inline)
 * ------------------------------------------------------------------
 */
export class PetaniPage {
  readonly page: Page;

  readonly searchInput: Locator;
  readonly filterKomoditas: Locator;
  readonly tambahButton: Locator;
  readonly exportPdfLink: Locator;
  readonly exportExcelLink: Locator;
  readonly exportCsvLink: Locator;
  readonly table: Locator;
  readonly tableRows: Locator;

  // Modal "Tambah Data Petani"
  readonly modalTambah: Locator;
  readonly formTambah: Locator;
  readonly namaInput: Locator;
  readonly teleponInput: Locator;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly passwordConfirmationInput: Locator;
  readonly luasLahanInput: Locator;
  readonly komoditasInput: Locator;
  readonly statusSelect: Locator;
  readonly alamatTextarea: Locator;
  readonly catatanTextarea: Locator;
  readonly simpanButton: Locator;
  readonly batalButton: Locator;

  // Modal konfirmasi hapus
  readonly modalHapus: Locator;
  readonly konfirmasiHapusButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.searchInput = page.locator('#searchInput');
    this.filterKomoditas = page.locator('#filterKomoditas');
    this.tambahButton = page.getByRole('button', { name: 'Tambah Petani' });
    this.exportPdfLink = page.getByRole('link', { name: 'PDF' });
    this.exportExcelLink = page.getByRole('link', { name: 'Excel' });
    this.exportCsvLink = page.getByRole('link', { name: 'CSV' });
    this.table = page.locator('#tablePetani');
    this.tableRows = page.locator('#tablePetani tbody tr');

    this.modalTambah = page.locator('#modalTambah');
    this.formTambah = page.locator('#formTambahPetani');
    this.namaInput = this.formTambah.locator('input[name="nama"]');
    this.teleponInput = this.formTambah.locator('input[name="telepon"]');
    this.emailInput = this.formTambah.locator('input[name="email"]');
    this.passwordInput = this.formTambah.locator('input[name="password"]');
    this.passwordConfirmationInput = this.formTambah.locator('input[name="password_confirmation"]');
    this.luasLahanInput = this.formTambah.locator('input[name="luas_lahan"]');
    this.komoditasInput = this.formTambah.locator('input[name="komoditas"]');
    this.statusSelect = this.formTambah.locator('select[name="status"]');
    this.alamatTextarea = this.formTambah.locator('textarea[name="alamat"]');
    this.catatanTextarea = this.formTambah.locator('textarea[name="catatan"]');
    this.simpanButton = this.formTambah.getByRole('button', { name: 'Simpan' });
    this.batalButton = this.modalTambah.getByRole('button', { name: 'Batal' });

    this.modalHapus = page.locator('#modalHapus');
    this.konfirmasiHapusButton = page.getByRole('button', { name: 'Ya, Hapus' });
  }

  async goto() {
    await this.page.goto('/admin/petani');
  }

  async openTambahModal() {
    await this.tambahButton.click();
    await this.modalTambah.waitFor({ state: 'visible' });
  }

  /**
   * Mengisi & submit form "Tambah Petani".
   * Karena submit form ini AJAX (lihat catatan di atas), pemanggil
   * disarankan memasang listener `page.on('dialog', ...)` SEBELUM
   * memanggil method ini jika mengetes skenario gagal validasi.
   */
  async isiFormTambah(data: {
    nama: string;
    telepon?: string;
    email: string;
    password: string;
    passwordConfirmation?: string;
    luasLahan?: string;
    status?: 'aktif' | 'nonaktif';
    alamat: string;
    catatan?: string;
  }) {
    await this.namaInput.fill(data.nama);
    if (data.telepon) await this.teleponInput.fill(data.telepon);
    await this.emailInput.fill(data.email);
    await this.passwordInput.fill(data.password);
    await this.passwordConfirmationInput.fill(data.passwordConfirmation ?? data.password);
    if (data.luasLahan) await this.luasLahanInput.fill(data.luasLahan);
    if (data.status) await this.statusSelect.selectOption(data.status);
    await this.alamatTextarea.fill(data.alamat);
    if (data.catatan) await this.catatanTextarea.fill(data.catatan);
  }

  async submitTambah() {
    await this.simpanButton.click();
  }

  rowByName(nama: string): Locator {
    return this.tableRows.filter({ hasText: nama });
  }

  async filterByText(query: string) {
    await this.searchInput.fill(query);
  }

  /**
   * Kolom status (badge Aktif/Non-aktif) adalah <td> yang bisa diklik
   * langsung untuk toggle (bukan tombol terpisah) — lihat
   * `onclick="togglePetaniStatus(id)"` pada blade template.
   */
  async toggleStatusForRow(nama: string) {
    const row = this.rowByName(nama);
    await row.getByTitle('Klik untuk mengubah status').click();
  }

  statusBadgeForRow(nama: string): Locator {
    return this.rowByName(nama).locator('td[id^="status-cell-"] .badge');
  }

  async editByName(nama: string) {
    await this.rowByName(nama).getByTitle('Edit').click();
  }

  async viewDetailByName(nama: string) {
    await this.rowByName(nama).getByTitle('Detail').click();
  }

  async deleteByName(nama: string) {
    const row = this.rowByName(nama);
    await row.getByTitle('Hapus').click();
    await this.modalHapus.waitFor({ state: 'visible' });
    await this.konfirmasiHapusButton.click();
  }
}
