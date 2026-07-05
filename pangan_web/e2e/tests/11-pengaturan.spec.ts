/**
 * 11-pengaturan.spec.ts
 * ------------------------------------------------------------------
 * Menguji admin/pengaturan/index.blade.php.
 *
 * TEMUAN QA: halaman ini TIDAK ADA link menu-nya di sidebar (lihat
 * komentar di layout/admin.blade.php — daftar menu berhenti di "Alert
 * Stok"), hanya bisa diakses lewat URL langsung. Selain itu,
 * PengaturanController@update HANYA mengembalikan pesan sukses statis
 * dan TIDAK benar-benar menyimpan input apa pun ke database — nilai
 * "Kelompok Tani Makmur" yang tampil di form adalah teks hardcoded di
 * Blade, bukan dibaca dari tabel pengaturan. Test di bawah menguji
 * PERILAKU AKTUAL ini (pesan sukses muncul), bukan mengasumsikan
 * datanya benar-benar tersimpan & persisten.
 */
import { test, expect } from '../fixtures/auth.fixtures';
import { PengaturanPage } from '../pages/PengaturanPage';

test.describe('Pengaturan Sistem', () => {
  test('hanya bisa diakses lewat URL langsung, tidak ada di menu sidebar', async ({ adminPage }) => {
    const pengaturan = new PengaturanPage(adminPage);
    await adminPage.goto('/admin');

    await expect(pengaturan.navItem('Pengaturan')).toHaveCount(0);
  });

  test('menampilkan form dengan nilai default "Kelompok Tani Makmur"', async ({ adminPage }) => {
    const pengaturan = new PengaturanPage(adminPage);
    await pengaturan.goto();

    await expect(pengaturan.orgNameInput).toHaveValue('Kelompok Tani Makmur');
  });

  test('submit menampilkan pesan sukses (meski tidak benar-benar tersimpan ke database)', async ({ adminPage }) => {
    const pengaturan = new PengaturanPage(adminPage);
    await pengaturan.goto();

    await pengaturan.updateOrgName('Kelompok Tani Sejahtera (Uji Coba)');

    await expect(adminPage.locator('body')).toContainText(/Pengaturan berhasil disimpan/i);

    // Reload untuk membuktikan nilainya TIDAK benar-benar tersimpan (kembali ke default hardcoded).
    await adminPage.reload();
    await expect(pengaturan.orgNameInput).toHaveValue('Kelompok Tani Makmur');
  });
});
