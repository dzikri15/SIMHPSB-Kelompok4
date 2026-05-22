<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class RoleAndPermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'admin@simhpsb.com'],
            [
                'name' => 'Admin SIMHPSB',
                'role' => 'admin',
                'password' => Hash::make('admin123'),
            ]
        );

        User::updateOrCreate(
            ['email' => 'petugas@simhpsb.com'],
            [
                'name' => 'Petugas SIMHPSB',
                'role' => 'petugas',
                'password' => Hash::make('petugas123'),
            ]
        );

        User::updateOrCreate(
            ['email' => 'petani@simhpsb.com'],
            [
                'name' => 'Petani SIMHPSB',
                'role' => 'petani',
                'password' => Hash::make('petani123'),
            ]
        );
    }
}
