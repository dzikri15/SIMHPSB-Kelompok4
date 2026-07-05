/**
 * PenggunaPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan admin/pengguna/index.blade.php dan create.blade.php.
 *
 * Field "Pilih Petani Terhubung" (#petaniField) hanya tampil & wajib
 * saat role = petani, dikontrol lewat togglePetaniField() di JS. Setelah
 * submit sukses, halaman create dirender ulang dengan modal
 * #modalPasswordBaru yang menampilkan password apa adanya (persis yang
 * diketik admin di form — BUKAN password random generated oleh sistem).
 */
import { type Page, type Locator, expect } from '@playwright/test';
import { BaseAdminPage } from './BaseAdminPage';

export interface PenggunaFormData {
  nama: string;
  email: string;
  role: 'admin' | 'petugas' | 'petani';
  petaniId?: string;
  password: string;
  passwordConfirmation: string;
}

export class PenggunaPage extends BaseAdminPage {
  readonly tambahLink: Locator;
  readonly table: Locator;

  // Form create
  readonly namaInput: Locator;
  readonly emailInput: Locator;
  readonly roleSelect: Locator;
  readonly petaniField: Locator;
  readonly petaniSelect: Locator;
  readonly passwordInput: Locator;
  readonly passwordConfirmInput: Locator;
  readonly submitButton: Locator;

  // Modal password baru
  readonly modalPasswordBaru: Locator;
  readonly passwordText: Locator;

  constructor(page: Page) {
    super(page);
    this.tambahLink = page.getByRole('link', { name: /Tambah Pengguna/i });
    this.table = page.locator('table.data-table');

    this.namaInput = page.locator('input[name="name"]');
    this.emailInput = page.locator('input[name="email"]');
    this.roleSelect = page.locator('#roleSelect');
    this.petaniField = page.locator('#petaniField');
    this.petaniSelect = page.locator('#petaniSelect');
    this.passwordInput = page.locator('input[name="password"]');
    this.passwordConfirmInput = page.locator('input[name="password_confirmation"]');
    this.submitButton = page.getByRole('button', { name: /Simpan Pengguna/i });

    this.modalPasswordBaru = page.locator('#modalPasswordBaru');
    this.passwordText = page.locator('#passwordText');
  }

  async goto() {
    await this.page.goto('/admin/pengguna');
  }

  async gotoCreate() {
    await this.page.goto('/admin/pengguna/create');
  }

  async fillForm(data: PenggunaFormData) {
    await this.namaInput.fill(data.nama);
    await this.emailInput.fill(data.email);
    await this.roleSelect.selectOption(data.role);
    if (data.role === 'petani' && data.petaniId) {
      await expect(this.petaniField).toBeVisible();
      await this.petaniSelect.selectOption(data.petaniId);
    }
    await this.passwordInput.fill(data.password);
    await this.passwordConfirmInput.fill(data.passwordConfirmation);
  }

  async submit() {
    await this.submitButton.click();
  }

  rowByEmail(email: string): Locator {
    return this.table.locator('tbody tr').filter({ hasText: email });
  }

  async openDeleteModal(nama: string) {
    await this.table
      .locator('tbody tr')
      .filter({ hasText: nama })
      .getByRole('button', { name: /Hapus/i })
      .click();
    await this.expectModalOpen('modalHapus');
  }

  async confirmDelete() {
    await this.page.locator('#formHapusPengguna button[type="submit"]').click();
  }
}
