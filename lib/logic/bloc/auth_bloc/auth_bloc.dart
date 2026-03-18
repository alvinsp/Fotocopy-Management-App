import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_event.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _auth.signInWithEmailAndPassword(
            email: event.email, password: event.password);
        emit(Authenticated(result.user!));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _auth.signOut();
      emit(Unauthenticated());
    });
  }
}
