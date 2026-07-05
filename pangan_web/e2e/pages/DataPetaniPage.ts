/**
 * DataPetaniPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan 4 view: admin/petani/index, create, edit, show.
 *
 * Ada DUA jalur untuk menambah petani di aplikasi ini:
 *  1) Modal cepat "Tambah Petani" di halaman index (#modalTambah) — field
 *     memakai atribut `name`, TANPA id/for, jadi locator harus di-scope
 *     ke dalam modal.
 *  2) Halaman penuh admin/petani/create — field-nya punya id + <label for>
 *     yang lengkap, jadi bisa pakai getByLabel().
 */
import { type Page, type Locator, expect } from '@playwright/test';
import { BaseAdminPage } from './BaseAdminPage';

export interface PetaniFormData {
  nama: string;
  telepon?: string;
  email: string;
  password: string;
  passwordConfirmation: string;
  luasLahan?: string;
  status?: 'aktif' | 'nonaktif';
  alamat: string;
  catatan?: string;
}

export class DataPetaniPage extends BaseAdminPage {
  readonly searchInput: Locator;
  readonly filterKomoditas: Locator;
  readonly tambahButton: Locator;
  readonly table: Locator;
  readonly modalTambahForm: Locator;

  constructor(page: Page) {
    super(page);
    this.searchInput = page.locator('#searchInput');
    this.filterKomoditas = page.locator('#filterKomoditas');
    this.tambahButton = page.getByRole('button', { name: /Tambah Petani/i });
    this.table = page.locator('#tablePetani');
    this.modalTambahForm = page.locator('#formTambahPetani');
  }

  async goto() {
    await this.page.goto('/admin/petani');
  }

  // ---------- Pencarian & filter (client-side, lihat filterTable() di blade) ----------
  async search(keyword: string) {
    await this.searchInput.fill(keyword);
  }

  async filterByKomoditas(value: string) {
    await this.filterKomoditas.selectOption(value);
  }

  rowByName(nama: string): Locator {
    return this.table.locator('tbody tr').filter({ hasText: nama });
  }

  async visibleRowCount(): Promise<number> {
    return this.table.locator('tbody tr:visible').count();
  }

  // ---------- Modal Tambah (index) ----------
  async openTambahModal() {
    await this.tambahButton.click();
    await this.expectModalOpen('modalTambah');
  }

  async fillModalForm(data: PetaniFormData) {
    const form = this.modalTambahForm;
    await form.locator('input[name="nama"]').fill(data.nama);
    if (data.telepon) await form.locator('input[name="telepon"]').fill(data.telepon);
    await form.locator('input[name="email"]').fill(data.email);
    await form.locator('input[name="password"]').fill(data.password);
    await form.locator('input[name="password_confirmation"]').fill(data.passwordConfirmation);
    if (data.luasLahan) await form.locator('input[name="luas_lahan"]').fill(data.luasLahan);
    if (data.status) await form.locator('select[name="status"]').selectOption(data.status);
    await form.locator('textarea[name="alamat"]').fill(data.alamat);
    if (data.catatan) await form.locator('textarea[name="catatan"]').fill(data.catatan);
  }

  async submitModalForm() {
    await this.modalTambahForm.locator('button[type="submit"]').click();
  }

  // ---------- Modal Hapus ----------
  async openDeleteModal(nama: string) {
    await this.rowByName(nama).locator('button[title="Hapus"]').click();
    await this.expectModalOpen('modalHapus');
    await expect(this.page.locator('#hapusNamaPetani')).toHaveText(nama);
  }

  async confirmDelete() {
    await this.page.locator('#formHapusPetani button[type="submit"]').click();
  }

  // ---------- Aksi baris ----------
  async toggleStatus(nama: string) {
    await this.rowByName(nama).locator('td[id^="status-cell-"]').click();
  }

  async openEdit(nama: string) {
    await this.rowByName(nama).locator('a[title="Edit"]').click();
  }

  async openDetail(nama: string) {
    await this.rowByName(nama).locator('a[title="Detail"]').click();
  }

  exportLink(format: 'PDF' | 'Excel' | 'CSV'): Locator {
    return this.page.getByRole('link', { name: new RegExp(format, 'i') });
  }

  // ---------- Halaman penuh: create / edit (id + label lengkap) ----------
  async gotoCreatePage() {
    await this.page.goto('/admin/petani/create');
  }

  async fillFullPageForm(data: PetaniFormData) {
    await this.page.getByLabel('Nama Petani').fill(data.nama);
    await this.page.getByLabel('Alamat').fill(data.alamat);
    if (data.telepon) await this.page.getByLabel('No. Telepon/HP').fill(data.telepon);
    await this.page.getByLabel('Email', { exact: false }).fill(data.email);
    // Password hanya ada di form create, tidak ada di form edit
    const passwordField = this.page.locator('#password');
    if (await passwordField.count()) {
      await passwordField.fill(data.password);
      await this.page.locator('#password_confirmation').fill(data.passwordConfirmation);
    }
    if (data.luasLahan) await this.page.getByLabel('Luas Lahan (m²)').fill(data.luasLahan);
    if (data.status) await this.page.locator('#status').selectOption(data.status);
    if (data.catatan) await this.page.getByLabel('Catatan').fill(data.catatan);
  }

  async submitFullPageForm() {
    await this.page.locator('button[type="submit"], input[type="submit"]').first().click();
  }
}
