/**
 * PetaniDashboardPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan resources/views/petani/dashboard.blade.php.
 *
 * PENTING: PetaniDashboardController akan abort(404) jika user yang
 * login tidak punya relasi `petani` yang valid (lihat catatan di
 * fixtures/test-data.ts perihal akun seed petani@simhpsb.com).
 */
import { type Page, type Locator, expect } from '@playwright/test';
import { BaseAdminPage } from './BaseAdminPage';

export class PetaniDashboardPage extends BaseAdminPage {
  readonly greeting: Locator;
  readonly summaryCards: Locator;
  readonly riwayatTable: Locator;

  constructor(page: Page) {
    super(page);
    this.greeting = page.locator('h2', { hasText: /Halo,/i });
    this.summaryCards = page.locator('.summary-card-title');
    this.riwayatTable = page.locator('table.petani-table');
  }

  async goto() {
    await this.page.goto('/petani');
  }

  async expectLoadedFor(name: string) {
    await expect(this.greeting).toContainText(name);
    await expect(this.summaryCards.first()).toBeVisible();
  }
}
