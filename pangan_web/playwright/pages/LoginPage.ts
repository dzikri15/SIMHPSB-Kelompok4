import { type Page, type Locator } from '@playwright/test';

/**
 * LoginPage
 * ------------------------------------------------------------------
 * Selector diambil langsung dari resources/views/auth/login.blade.php
 * pada project yang di-upload (bukan tebakan), sehingga locator di
 * bawah ini valid terhadap markup HTML yang sesungguhnya dirender.
 * ------------------------------------------------------------------
 */
export class LoginPage {
  readonly page: Page;

  readonly identifierInput: Locator;
  readonly passwordInput: Locator;
  readonly rememberCheckbox: Locator;
  readonly submitButton: Locator;
  readonly togglePasswordButton: Locator;
  readonly errorAlert: Locator;
  readonly identifierHint: Locator;
  readonly heading: Locator;
  readonly subheading: Locator;
  readonly brandName: Locator;
  readonly footer: Locator;
  readonly darkModeToggle: Locator;

  constructor(page: Page) {
    this.page = page;
    this.identifierInput = page.locator('#identifier');
    this.passwordInput = page.locator('#password');
    this.rememberCheckbox = page.locator('input[name="remember"]');
    this.submitButton = page.locator('button.btn-login');
    this.togglePasswordButton = page.locator('button.toggle-pw');
    this.errorAlert = page.locator('.error-alert');
    this.identifierHint = page.locator('.small-hint');
    this.heading = page.locator('.login-header h2');
    this.subheading = page.locator('.login-header p');
    this.brandName = page.locator('.brand-name');
    this.footer = page.locator('.login-footer');
    this.darkModeToggle = page.locator('#darkModeToggle');
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

  async togglePasswordVisibility() {
    await this.togglePasswordButton.click();
  }

  async passwordInputType(): Promise<string | null> {
    return this.passwordInput.getAttribute('type');
  }
}
