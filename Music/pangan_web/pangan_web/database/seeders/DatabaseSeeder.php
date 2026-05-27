<?php

namespace Database\Seeders;

use App\Models\Alert;
use App\Models\Distribusi;
use App\Models\Gudang;
use App\Models\Harga;
use App\Models\Lahan;
use App\Models\Panen;
use App\Models\Petani;
use App\Models\Stok;
use App\Models\User;
use Illuminate\Database\Seeder;
use Database\Seeders\RoleAndPermissionSeeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call(RoleAndPermissionSeeder::class);

        User::updateOrCreate(
            ['email' => 'admin@simhpsb.com'],
            [
                'name' => 'Admin SIMHPSB',
                'role' => 'admin',
                'password' => bcrypt('password'),
            ]
        );

        User::updateOrCreate(
            ['email' => 'petugas@simhpsb.com'],
            [
                'name' => 'Petugas SIMHPSB',
                'role' => 'petugas',
                'password' => bcrypt('password'),
            ]
        );

        User::updateOrCreate(
            ['email' => 'petani@simhpsb.com'],
            [
                'name' => 'Petani SIMHPSB',
                'role' => 'petani',
                'password' => bcrypt('password'),
            ]
        );

        $petani1 = Petani::updateOrCreate(
            ['email' => 'petani1@simhpsb.com'],
            [
                'nama' => 'Pak Budi',
                'nik' => '3201010101010001',
                'alamat' => 'Desa Sawah, Kecamatan A',
                'telepon' => '0211234567',
                'no_hp' => '081234567890',
                'tanggal_lahir' => '1980-05-12',
                'status' => 'aktif',
                'luas_lahan' => 1.5,
                'komoditas' => 'beras',
                'catatan' => 'Petani padi organik',
            ]
        );

        $petani2 = Petani::updateOrCreate(
            ['email' => 'petani2@simhpsb.com'],
            [
                'nama' => 'Bu Sari',
                'nik' => '3201010101010002',
                'alamat' => 'Desa Sawah, Kecamatan B',
                'telepon' => '0217654321',
                'no_hp' => '082345678901',
                'tanggal_lahir' => '1985-08-20',
                'status' => 'aktif',
                'luas_lahan' => 2.0,
                'komoditas' => 'beras',
                'catatan' => 'Petani lokal',
            ]
        );

        $lahan1 = Lahan::updateOrCreate(
            ['nama_lahan' => 'Lahan Sawah A'],
            [
                'petani_id' => $petani1->id,
                'luas' => 1.2,
                'lokasi' => 'Dusun Tengah',
                'jenis_tanah' => 'sawah',
                'status' => 'aktif',
            ]
        );

        $lahan2 = Lahan::updateOrCreate(
            ['nama_lahan' => 'Lahan Sawah B'],
            [
                'petani_id' => $petani2->id,
                'luas' => 2.0,
                'lokasi' => 'Dusun Selatan',
                'jenis_tanah' => 'sawah',
                'status' => 'aktif',
            ]
        );

        $panen1 = Panen::updateOrCreate(
            ['lahan_id' => $lahan1->id, 'tanggal_panen' => '2026-05-15'],
            [
                'jumlah_gabah' => 1200,
                'harga_gabah_per_kg' => 4200,
                'konversi_beras' => 720,
                'catatan' => 'Panen padi IR3',
            ]
        );

        $panen2 = Panen::updateOrCreate(
            ['lahan_id' => $lahan2->id, 'tanggal_panen' => '2026-05-16'],
            [
                'jumlah_gabah' => 1500,
                'harga_gabah_per_kg' => 4100,
                'konversi_beras' => 900,
                'catatan' => 'Panen padi unggul',
            ]
        );

        $gudang1 = Gudang::updateOrCreate(
            ['nama_gudang' => 'Gudang Sentral'],
            [
                'lokasi' => 'Kota A',
                'kapasitas' => 5000,
                'status' => 'aktif',
            ]
        );

        $gudang2 = Gudang::updateOrCreate(
            ['nama_gudang' => 'Gudang Cabang'],
            [
                'lokasi' => 'Kota B',
                'kapasitas' => 3000,
                'status' => 'aktif',
            ]
        );

        Stok::updateOrCreate(
            ['gudang_id' => $gudang1->id],
            [
                'jumlah_stok' => 1200,
                'batas_minimum' => 500,
                'tanggal_update' => '2026-05-20',
                'catatan' => 'Stok cukup untuk 2 minggu',
            ]
        );

        Stok::updateOrCreate(
            ['gudang_id' => $gudang2->id],
            [
                'jumlah_stok' => 400,
                'batas_minimum' => 500,
                'tanggal_update' => '2026-05-20',
                'catatan' => 'Perlu refill stok',
            ]
        );

        Harga::updateOrCreate(
            ['komoditas' => 'Beras'],
            [
                'harga_per_kg' => 4500,
                'tanggal_berlaku' => '2026-05-20',
                'sumber' => 'Pasar Tradisional',
            ]
        );

        Harga::updateOrCreate(
            ['komoditas' => 'Gabah'],
            [
                'harga_per_kg' => 3200,
                'tanggal_berlaku' => '2026-05-20',
                'sumber' => 'Pasar Lokal',
            ]
        );

        Distribusi::updateOrCreate(
            ['gudang_id' => $gudang1->id, 'tanggal_distribusi' => '2026-05-20'],
            [
                'jumlah_distribusi' => 250,
                'tujuan' => 'Pasar Kota A',
                'catatan' => 'Distribusi kebutuhan mingguan',
            ]
        );

        Distribusi::updateOrCreate(
            ['gudang_id' => $gudang2->id, 'tanggal_distribusi' => '2026-05-21'],
            [
                'jumlah_distribusi' => 150,
                'tujuan' => ' Distributor Lokal',
                'catatan' => 'Distribusi cadangan',
            ]
        );

        Alert::updateOrCreate(
            ['komoditas' => 'Beras', 'stok_saat_ini' => 400],
            [
                'batas_minimum' => 500,
                'status' => 'aktif',
                'ditangani_oleh' => User::where('role', 'petugas')->first()->id,
            ]
        );

        Alert::updateOrCreate(
            ['komoditas' => 'Gabah', 'stok_saat_ini' => 1200],
            [
                'batas_minimum' => 800,
                'status' => 'proses',
                'ditangani_oleh' => User::where('role', 'petugas')->first()->id,
            ]
        );
    }
}
