/**
 * PengaturanPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan admin/pengaturan/index.blade.php — halaman paling
 * sederhana di aplikasi ini, cuma satu field "Nama Organisasi".
 */
import { type Page, type Locator } from '@playwright/test';
import { BaseAdminPage } from './BaseAdminPage';

export class PengaturanPage extends BaseAdminPage {
  readonly orgNameInput: Locator;
  readonly submitButton: Locator;

  constructor(page: Page) {
    super(page);
    this.orgNameInput = page.locator('input[name="org_name"]');
    this.submitButton = page.getByRole('button', { name: /Simpan Pengaturan/i });
  }

  async goto() {
    await this.page.goto('/admin/pengaturan');
  }

  async updateOrgName(name: string) {
    await this.orgNameInput.fill(name);
    await this.submitButton.click();
  }
}
