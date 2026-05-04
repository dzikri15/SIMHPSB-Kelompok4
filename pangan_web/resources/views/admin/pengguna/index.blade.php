@extends('layout.admin')

@section('title', 'Manajemen Pengguna')
@section('page-title', 'Manajemen Pengguna')
@section('page-subtitle', 'Kelola akun pengguna sistem')

@section('content')

<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Daftar Pengguna</div>
            <div class="card-subtitle">Semua pengguna terdaftar dalam sistem</div>
        </div>
        <button class="btn btn-primary btn-sm" onclick="openModal('modalTambahPengguna')">
            <i class="fas fa-plus"></i> Tambah Pengguna
        </button>
    </div>

    <div class="table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Nama</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Status</th>
                    <th>Aksi</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Admin User</strong></td>
                    <td>test@example.com</td>
                    <td><span class="badge badge-green">Admin</span></td>
                    <td><span class="badge badge-green">Aktif</span></td>
                    <td>
                        <button class="btn btn-secondary btn-sm"><i class="fas fa-edit"></i> Edit</button>
                        <button class="btn btn-danger btn-sm"><i class="fas fa-trash"></i> Hapus</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

@endsection
