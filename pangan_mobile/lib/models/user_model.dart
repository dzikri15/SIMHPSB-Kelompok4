// lib/models/user_model.dart
 
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? petaniId;
 
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.petaniId,
  });
 
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:       json['id'] as int,
        name:     json['name'] as String,
        email:    json['email'] as String,
        role:     json['role'] as String? ?? '',
        petaniId: json['petani_id'] as int?,
      );
 
  Map<String, dynamic> toJson() => {
        'id':        id,
        'name':      name,
        'email':     email,
        'role':      role,
        'petani_id': petaniId,
      };
 
  bool get isAdmin   => role == 'admin';
  bool get isPetugas => role == 'petugas';
  bool get isPetani  => role == 'petani';
}
 