import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_event.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _activationController = TextEditingController();
  String _selectedRole = 'karyawan'; // Default role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun Toko")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email Baru', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              // Dropdown Pilihan Role
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: ['owner', 'karyawan'].map((role) {
                  return DropdownMenuItem(
                      value: role, child: Text(role.toUpperCase()));
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
                decoration: const InputDecoration(labelText: 'Role User'),
              ),
              const SizedBox(height: 16),
              // Input Kode Aktivasi Rahasia
              TextField(
                controller: _activationController,
                decoration: const InputDecoration(
                  labelText: 'Kode Aktivasi Rahasia',
                  hintText: 'Masukkan kode dari Developer',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  onPressed: () {
                    // Panggil Event Register (Pastikan sudah dibuat di AuthBloc)
                    context.read<AuthBloc>().add(RegisterRequested(
                          _emailController.text,
                          _passwordController.text,
                          _selectedRole,
                          _activationController.text,
                        ));
                  },
                  child: const Text("Daftar Sekarang",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
