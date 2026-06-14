<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TujuanDistribusiSeeder extends Seeder
{
    public function run(): void
    {
        $items = [
            'MBG Dapur 1',
            'MBG Dapur 2',
            'MBG Dapur 3',
            'Toko Rudi',
            'Toko Barokah',
            'Lainnya',
        ];

        foreach ($items as $nama) {
            DB::table('tujuan_distribusi')->updateOrInsert([
                'nama' => $nama,
            ], [
                'updated_at' => now(),
                'created_at' => now(),
            ]);
        }
    }
}
