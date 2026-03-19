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
            email: event.email, password: event.password);

        final firebaseUser = result.user;

        if (firebaseUser != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

          if (userDoc.exists) {
            final myUser =
                UserModel.fromFirestore(userDoc.data()!, firebaseUser.uid);
            emit(Authenticated(myUser));
          } else {
            emit(AuthError("Data profil tidak ditemukan di database."));
          }
        }
      } catch (e) {
        emit(AuthError(e.toString()));
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
