import { type Page, type Locator } from '@playwright/test';

/**
 * PanenPage
 * ------------------------------------------------------------------
 * Selector diambil dari resources/views/admin/panen/index.blade.php.
 *
 * CATATAN PENTING (lihat README.md bagian "Temuan Perbedaan"):
 * Dibanding "Test Case Input Data Panen.xlsx", pada kode sumber
 * saat ini:
 *  - TIDAK ADA field "Rasio Konversi (%)" sama sekali.
 *  - Field foto bukti panen ("foto_bukti") kini WAJIB (required)
 *    -- validasi server: required|image|mimes:jpg,jpeg,png|max:5120.
 *  - Dropdown Petani adalah komponen custom (bukan <select> native):
 *    klik untuk membuka panel pencarian, lalu klik salah satu <li>.
 *  - Kolom tabel riwayat: Petani, Hasil Gabah, Penghasilan (Rp),
 *    Foto, Musim, Tanggal, Aksi (bukan "Beras Hasil").
 * ------------------------------------------------------------------
 */
export class PanenPage {
  readonly page: Page;

  readonly errorBanner: Locator;
  readonly petaniDisplay: Locator;
  readonly petaniSearchInput: Locator;
  readonly petaniIdHidden: Locator;
  readonly musimSelect: Locator;
  readonly tanggalPanenInput: Locator;
  readonly jumlahGabahInput: Locator;
  readonly komoditasSelect: Locator;
  readonly catatanTextarea: Locator;
  readonly fotoDropZone: Locator;
  readonly fotoBuktiInput: Locator;
  readonly submitButton: Locator;
  readonly riwayatTable: Locator;
  readonly riwayatRows: Locator;

  constructor(page: Page) {
    this.page = page;
    this.errorBanner = page.locator('.alert-banner.danger');
    this.petaniDisplay = page.locator('#petaniDisplay');
    this.petaniSearchInput = page.locator('#petaniSearch');
    this.petaniIdHidden = page.locator('#petaniIdInput');
    this.musimSelect = page.locator('select[name="musim"]');
    this.tanggalPanenInput = page.locator('input[name="tanggal_panen"]');
    this.jumlahGabahInput = page.locator('#jumlahGabah');
    this.komoditasSelect = page.locator('select[name="komoditas"]');
    this.catatanTextarea = page.locator('textarea[name="catatan"]');
    this.fotoDropZone = page.locator('#foto-drop-zone');
    this.fotoBuktiInput = page.locator('#foto_bukti_input');
    this.submitButton = page.getByRole('button', { name: 'Simpan Catatan Panen' });
    this.riwayatTable = page.locator('.card', { hasText: 'Riwayat Panen Terbaru' }).locator('table');
    this.riwayatRows = page.locator('tr.panen-row');
  }

  async goto() {
    await this.page.goto('/admin/panen');
  }

  /** Memilih petani lewat custom searchable dropdown. */
  async pilihPetani(namaPetani: string) {
    await this.petaniDisplay.click();
    await this.petaniSearchInput.fill(namaPetani);
    await this.page.locator('li.petani-opt', { hasText: namaPetani }).first().click();
  }

  async isiFormPanen(data: {
    petani: string;
    musim: 'Kemarau' | 'Hujan';
    tanggalPanen?: string; // yyyy-mm-dd
    jumlahGabah: string;
    catatan?: string;
    fotoPath?: string;
  }) {
    await this.pilihPetani(data.petani);
    await this.musimSelect.selectOption(data.musim);
    if (data.tanggalPanen) {
      await this.tanggalPanenInput.fill(data.tanggalPanen);
    }
    await this.jumlahGabahInput.fill(data.jumlahGabah);
    if (data.catatan) {
      await this.catatanTextarea.fill(data.catatan);
    }
    if (data.fotoPath) {
      await this.fotoBuktiInput.setInputFiles(data.fotoPath);
    }
  }

  async submit() {
    await this.submitButton.click();
  }

  rowForPetani(namaPetani: string): Locator {
    return this.riwayatRows.filter({ hasText: namaPetani });
  }

  editRowFor(namaPetani: string): Locator {
    return this.rowForPetani(namaPetani).getByRole('link', { name: 'Edit' });
  }

  deleteButtonFor(namaPetani: string): Locator {
    return this.rowForPetani(namaPetani).getByRole('button', { name: 'Hapus' });
  }
}
