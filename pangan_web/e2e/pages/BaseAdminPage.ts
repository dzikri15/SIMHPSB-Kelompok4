/**
 * BaseAdminPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan resources/views/layout/admin.blade.php — bagian yang
 * SAMA di semua halaman admin/petugas: sidebar, topbar, dark mode toggle,
 * dan mekanisme modal (.modal-overlay.open).
 *
 * CATATAN PENTING (temuan QA soal modal):
 * Modal di layout ini TIDAK memakai display:none/block untuk sembunyi-
 * tampil, melainkan class `.open` yang mengubah `opacity` & `pointer-events`
 * lewat CSS transition:
 *
 *    .modal-overlay          { opacity: 0; pointer-events: none; }
 *    .modal-overlay.open     { opacity: 1; pointer-events: auto; }
 *
 * Konsekuensinya untuk pengujian: `expect(modal).toBeVisible()` TIDAK
 * bisa dipakai untuk memastikan modal benar-benar tertutup, karena
 * elemen tetap ada di DOM dengan display:flex — Playwright akan tetap
 * menganggapnya "visible" walau opacity: 0. Yang benar adalah mengecek
 * class-nya langsung dengan `toHaveClass(/open/)` / `not.toHaveClass(/open/)`.
 * Kelas Base ini menyediakan helper supaya semua spec file konsisten
 * memakai cara yang benar.
 */
import { type Page, type Locator, expect } from '@playwright/test';

export class BaseAdminPage {
  readonly page: Page;
  readonly sidebar: Locator;
  readonly darkModeToggle: Locator;
  readonly logoutLink: Locator;
  readonly topbarTitle: Locator;

  constructor(page: Page) {
    this.page = page;
    this.sidebar = page.locator('.sidebar, #sidebar').first();
    this.darkModeToggle = page.locator('#darkModeToggle');
    // Logout sesungguhnya berupa <a> yang mem-preventDefault lalu men-submit
    // form tersembunyi (#logout-form) lewat JS — BUKAN tombol submit biasa.
    this.logoutLink = page.locator('a.user-logout, a[title="Logout"]');
    this.topbarTitle = page.locator('.topbar h1, .page-title').first();
  }

  modal(modalId: string): Locator {
    return this.page.locator(`#${modalId}`);
  }

  /** Pakai ini, JANGAN pakai expect(modal).toBeVisible() — lihat catatan di atas kelas. */
  async expectModalOpen(modalId: string) {
    await expect(this.modal(modalId)).toHaveClass(/open/);
  }

  async expectModalClosed(modalId: string) {
    await expect(this.modal(modalId)).not.toHaveClass(/open/);
  }

  async closeModalViaBackdrop(modalId: string) {
    // Klik di area overlay tapi di luar kotak .modal supaya tidak kena elemen anak.
    await this.modal(modalId).click({ position: { x: 5, y: 5 } });
  }

  async logout() {
    await this.logoutLink.click();
  }

  /**
   * Dark mode diimplementasikan dengan menambah class `dark` (BUKAN `dark-mode`)
   * ke elemen <html>, dan status-nya disimpan di localStorage key
   * `simhpsb_dark_mode` (lihat resources/views/layout/admin.blade.php baris ~936
   * dan public/js/dark-mode.js).
   */
  async isDarkModeActive(): Promise<boolean> {
    return this.page.evaluate(() => document.documentElement.classList.contains('dark'));
  }

  async toggleDarkMode() {
    await this.darkModeToggle.click();
  }

  navItem(label: string): Locator {
    return this.page.locator('.sidebar a, #sidebar a').filter({ hasText: label });
  }

  async gotoViaSidebar(label: string) {
    await this.navItem(label).click();
  }
}
