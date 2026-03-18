// presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_event.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_state.dart';
import 'package:fotocopy_app/presentation/screens/dashboad_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Kalau berhasil login, pindah ke Dashboard
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()));
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.print, size: 80, color: Colors.indigo),
              const SizedBox(height: 24),
              const Text("Admin Toko Fotocopy",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true),
              const SizedBox(height: 32),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return state is AuthLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(LoginRequested(
                                _emailController.text,
                                _passwordController.text));
                          },
                          child: const Text("Masuk"),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
