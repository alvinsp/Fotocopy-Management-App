import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/data/models/user_model.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_event.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        final user = result.user;

        if (user != null) {
          await user.reload();

          if (!user.emailVerified) {
            await _auth.signOut();
            emit(AuthError(
                "Akun belum aktif. Silakan verifikasi email Anda di inbox/spam terlebih dahulu."));
            return;
          }
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final myUser = UserModel.fromFirestore(userDoc.data()!, user.uid);
            emit(Authenticated(myUser));
          }
        }
      } catch (e) {
        emit(AuthError("Login Gagal: Email atau Password salah."));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        if (event.activationCode != "BEKALAN2026") {
          emit(AuthError("Kode Aktivasi Salah! Hubungi Owner."));
          return;
        }
        final result = await _auth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        if (result.user != null) {
          await result.user!.sendEmailVerification();

          final newUser = UserModel(
            uid: result.user!.uid,
            email: event.email,
            nama: event.nama,
            role: event.role,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(result.user!.uid)
              .set(newUser.toMap());

          await _auth.signOut();

          emit(AuthError(
              "Email aktivasi telah dikirim ke ${event.email}. Silakan cek inbox/spam dan verifikasi sebelum login."));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _auth.sendPasswordResetEmail(email: event.email);

        emit(AuthInitial());
        emit(AuthError("Link reset sudah dikirim! Cek inbox/spam email kamu."));
      } catch (e) {
        emit(AuthError("Gagal: ${e.toString()}"));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _auth.signOut();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
