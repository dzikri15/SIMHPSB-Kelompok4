/**
 * DashboardPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan resources/views/admin/dashboard.blade.php.
 * Dipakai baik oleh role admin (/admin) maupun petugas (/petugas) karena
 * keduanya dilayani oleh controller & view yang sama.
 */
import { type Page, type Locator, expect } from '@playwright/test';
import { BaseAdminPage } from './BaseAdminPage';

export class DashboardPage extends BaseAdminPage {
  readonly statCards: Locator;
  readonly chartStokTarget: Locator;
  readonly chartTrenPanen: Locator;

  constructor(page: Page) {
    super(page);
    this.statCards = page.locator('.stat-value');
    this.chartStokTarget = page.locator('#chartStokTarget');
    this.chartTrenPanen = page.locator('#chartTrenPanen');
  }

  async gotoAsAdmin() {
    await this.page.goto('/admin');
  }

  async gotoAsPetugas() {
    await this.page.goto('/petugas');
  }

  async expectLoaded() {
    await expect(this.page.locator('body')).toBeVisible();
    // Minimal harus ada minimal satu kartu statistik yang tampil
    await expect(this.statCards.first()).toBeVisible();
  }
}
