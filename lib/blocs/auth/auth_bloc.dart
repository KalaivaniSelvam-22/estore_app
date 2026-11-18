
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:estore_app/blocs/auth/auth_event.dart';
import 'package:estore_app/blocs/auth/auth_state.dart';
import 'package:estore_app/core/errors/auth_exception.dart';
import 'package:estore_app/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({
    required this.authService,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RestoreSessionRequested>(_onRestoreSessionRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = authService.login(
        userCode: event.userCode,
        password: event.password,
      );

      await authService.saveSession(user);

      emit(AuthAuthenticated(user));
    } on AuthException catch (error) {
      emit(AuthUnauthenticated(errorMessage: error.message));
    } catch (_) {
      emit(
        const AuthUnauthenticated(
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onRestoreSessionRequested(
    RestoreSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await authService.restoreSession();

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authService.clearSession();
    emit(const AuthUnauthenticated());
  }
}
