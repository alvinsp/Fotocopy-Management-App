abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email, password;
  LoginRequested(this.email, this.password);
}

class LogoutRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String email, password, role, activationCode;
  RegisterRequested(this.email, this.password, this.role, this.activationCode);
}
