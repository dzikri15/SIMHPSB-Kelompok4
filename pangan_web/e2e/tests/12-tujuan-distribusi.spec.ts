/**
 * 12-tujuan-distribusi.spec.ts
 * ------------------------------------------------------------------
 * Menguji admin/tujuan-distribusi/index.blade.php.
 *
 * Aturan bisnis dari TujuanDistribusiController: nama tujuan harus unik,
 * dan tujuan TIDAK BISA dihapus jika namanya pernah dipakai di kolom
 * `keterangan` transaksi stok manapun. Untuk menguji ini secara mandiri
 * (tanpa bergantung pada urutan eksekusi file test lain), test di bawah
 * membuat tujuan baru sendiri, memakainya lewat satu transaksi Stok,
 * baru mencoba menghapusnya.
 */
import { test, expect } from '../fixtures/auth.fixtures';
import { TujuanDistribusiPage } from '../pages/TujuanDistribusiPage';
import { StokPage } from '../pages/StokPage';
import { buildTujuanNama, DUMMY_IMAGE_PATH } from '../fixtures/test-data';

test.describe('Tujuan Distribusi — index & tambah', () => {
  test('menampilkan daftar tujuan distribusi', async ({ adminPage }) => {
    const tujuan = new TujuanDistribusiPage(adminPage);
    await tujuan.goto();

    await expect(tujuan.table).toBeVisible();
    await expect(tujuan.tambahButton).toBeVisible();
  });

  test('berhasil menambah tujuan distribusi baru', async ({ adminPage }) => {
    const tujuan = new TujuanDistribusiPage(adminPage);
    const nama = buildTujuanNama();
    await tujuan.goto();

    await tujuan.openTambahModal();
    await tujuan.submitTambah(nama);

    await expect(adminPage.locator('body')).toContainText(/ditambahkan/i);
    await expect(tujuan.rowByNama(nama)).toBeVisible();
  });

  test('menolak nama tujuan yang sudah ada (unique)', async ({ adminPage }) => {
    const tujuan = new TujuanDistribusiPage(adminPage);
    await tujuan.goto();

    await tujuan.openTambahModal();
    await tujuan.submitTambah('Toko Rudi'); // sudah ada dari seeder

    await expect(adminPage.locator('body')).toContainText(/sudah ada|already been taken|nama/i);
  });

  test('menolak submit dengan nama kosong (validasi HTML5)', async ({ adminPage }) => {
    const tujuan = new TujuanDistribusiPage(adminPage);
    await tujuan.goto();

    await tujuan.openTambahModal();
    await tujuan.namaInputModal.fill('');
    await adminPage.locator('#modalTambahTujuan button[type="submit"]').click();

    await tujuan.expectModalOpen('modalTambahTujuan');
  });
});

test.describe('Tujuan Distribusi — hapus', () => {
  test('modal hapus menampilkan nama tujuan yang benar dan bisa dibatalkan', async ({ adminPage }) => {
    const tujuan = new TujuanDistribusiPage(adminPage);
    const nama = buildTujuanNama();
    await tujuan.goto();
    await tujuan.openTambahModal();
    await tujuan.submitTambah(nama);

    await tujuan.openHapusModal(nama);
    await adminPage.locator('#modalHapusTujuan button', { hasText: 'Batal' }).click();
    await tujuan.expectModalClosed('modalHapusTujuan');
    await expect(tujuan.rowByNama(nama)).toBeVisible();
  });

  test('berhasil menghapus tujuan yang belum pernah dipakai di transaksi', async ({ adminPage }) => {
    const tujuan = new TujuanDistribusiPage(adminPage);
    const nama = buildTujuanNama();
    await tujuan.goto();
    await tujuan.openTambahModal();
    await tujuan.submitTambah(nama);

    await tujuan.openHapusModal(nama);
    await tujuan.confirmHapus();

    await expect(adminPage.locator('body')).toContainText(/dihapus/i);
    await expect(tujuan.rowByNama(nama)).toHaveCount(0);
  });

  test('tidak bisa menghapus tujuan yang sudah dipakai di transaksi stok', async ({ adminPage }) => {
    const tujuan = new TujuanDistribusiPage(adminPage);
    const nama = buildTujuanNama();

    // 1. Buat tujuan baru
    await tujuan.goto();
    await tujuan.openTambahModal();
    await tujuan.submitTambah(nama);

    // 2. Pakai tujuan ini di satu transaksi stok Keluar-Beras
    const stok = new StokPage(adminPage);
    await stok.goto();
    await stok.openTambahModal();
    await stok.selectKomoditas('Beras');
    await stok.selectJenis('keluar');
    await stok.jumlahInput.fill('5');
    await stok.tujuanSelect.selectOption(nama);
    await stok.keteranganText.fill('Dipakai oleh test tujuan-distribusi');
    await stok.fotoBuktiInput.setInputFiles(DUMMY_IMAGE_PATH);
    await stok.submitTransaksiButton.click();
    await expect(adminPage).toHaveURL(/\/admin\/stok$/);

    // 3. Coba hapus tujuan tersebut — harus ditolak
    await tujuan.goto();
    await tujuan.openHapusModal(nama);
    await tujuan.confirmHapus();

    await expect(adminPage.locator('body')).toContainText(/tidak dapat dihapus karena sudah digunakan/i);
    await expect(tujuan.rowByNama(nama)).toBeVisible();
  });
});
