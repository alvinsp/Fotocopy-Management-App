abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email, password;
  LoginRequested(this.email, this.password);
}

class LogoutRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String nama;
  final String role;
  final String activationCode;

  RegisterRequested({
    required this.email,
    required this.password,
    required this.nama,
    required this.role,
    required this.activationCode,
  });
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  ForgotPasswordRequested(this.email);
}
