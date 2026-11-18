import 'package:bloc_test/bloc_test.dart';
import 'package:estore_app/blocs/auth/auth_bloc.dart';
import 'package:estore_app/blocs/auth/auth_event.dart';
import 'package:estore_app/blocs/auth/auth_state.dart';
import 'package:estore_app/core/errors/auth_exception.dart';
import 'package:estore_app/models/app_user.dart';
import 'package:estore_app/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  const adminUser = AppUser(
    userCode: '1001',
    userName: 'Admin',
    userRole: UserRole.admin,
  );

  const superAdminUser = AppUser(
    userCode: '1002',
    userName: 'Super Admin',
    userRole: UserRole.superAdmin,
  );

  setUp(() {
    mockAuthService = MockAuthService();
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits loading and authenticated when Admin login succeeds',
      build: () {
        when(() => mockAuthService.login(userCode: '1001', password: 'admin'))
            .thenReturn(adminUser);

        when(() => mockAuthService.saveSession(adminUser))
            .thenAnswer((_) async {});

        return AuthBloc(authService: mockAuthService);
      },
      act: (bloc) {
        bloc.add(const LoginRequested(userCode: '1001', password: 'admin'));
      },
      expect: () => [const AuthLoading(), const AuthAuthenticated(adminUser)],
      verify: (_) {
        verify(() => mockAuthService.saveSession(adminUser)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits loading and authenticated when Super Admin login succeeds',
      build: () {
        when(
          () => mockAuthService.login(userCode: '1002', password: 'superadmin'),
        ).thenReturn(superAdminUser);

        when(() => mockAuthService.saveSession(superAdminUser))
            .thenAnswer((_) async {});

        return AuthBloc(authService: mockAuthService);
      },
      act: (bloc) {
        bloc.add(
          const LoginRequested(userCode: '1002', password: 'superadmin'),
        );
      },
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(superAdminUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits an error when login credentials are invalid',
      build: () {
        when(() => mockAuthService.login(userCode: '1001', password: 'wrong'))
            .thenThrow(
              const AuthException(message: 'Invalid user code or password'),
            );

        return AuthBloc(authService: mockAuthService);
      },
      act: (bloc) {
        bloc.add(const LoginRequested(userCode: '1001', password: 'wrong'));
      },
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(
          errorMessage: 'Invalid user code or password',
        ),
      ],
      verify: (_) {
        verifyNever(() => mockAuthService.saveSession(adminUser));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'resets authentication state after logout',
      build: () {
        when(() => mockAuthService.login(userCode: '1001', password: 'admin'))
            .thenReturn(adminUser);

        when(() => mockAuthService.saveSession(adminUser))
            .thenAnswer((_) async {});

        when(() => mockAuthService.clearSession()).thenAnswer((_) async {});

        return AuthBloc(authService: mockAuthService);
      },
      act: (bloc) async {
        bloc.add(const LoginRequested(userCode: '1001', password: 'admin'));

        await bloc.stream.firstWhere((state) => state is AuthAuthenticated);

        bloc.add(const LogoutRequested());
      },
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(adminUser),
        const AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(() => mockAuthService.clearSession()).called(1);
      },
    );
  });
}
