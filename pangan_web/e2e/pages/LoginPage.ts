/**
 * LoginPage.ts
 * ------------------------------------------------------------------
 * Merepresentasikan resources/views/auth/login.blade.php
 */
import { type Page, type Locator, expect } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly identifierInput: Locator;
  readonly passwordInput: Locator;
  readonly rememberCheckbox: Locator;
  readonly submitButton: Locator;
  readonly errorAlert: Locator;
  readonly togglePasswordButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.identifierInput = page.locator('#identifier');
    this.passwordInput = page.locator('#password');
    this.rememberCheckbox = page.locator('input[name="remember"]');
    this.submitButton = page.locator('button[type="submit"]');
    this.errorAlert = page.locator('.error-alert');
    this.togglePasswordButton = page.locator('.toggle-pw');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(identifier: string, password: string, remember = false) {
    await this.identifierInput.fill(identifier);
    await this.passwordInput.fill(password);
    if (remember) {
      await this.rememberCheckbox.check();
    }
    await this.submitButton.click();
  }

  async expectValidationMessage(fieldLocator: Locator) {
    // Field required memakai validasi HTML5 bawaan browser, bukan pesan custom di DOM.
    const isValid = await fieldLocator.evaluate((el: HTMLInputElement) => el.validity.valid);
    expect(isValid).toBeFalsy();
  }

  async expectLoginError() {
    await expect(this.errorAlert).toBeVisible();
  }
}
