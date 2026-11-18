
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:estore_app/blocs/auth/auth_bloc.dart';
import 'package:estore_app/blocs/auth/auth_event.dart';
import 'package:estore_app/blocs/auth/auth_state.dart';
import 'package:estore_app/core/di/injection.dart';
import 'package:estore_app/screens/login_screen.dart';
import 'package:estore_app/screens/role_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const MyApp());
}

class AppColors {
  static const Color primary = Color(0xFF5B4BDB);
  static const Color secondary = Color(0xFF9C6ADE);
  static const Color background = Color(0xFFF6F5FF);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF292547);
  static const Color accent = Color(0xFFFFB547);
  static const Color success = Color(0xFF20A779);
  static const Color error = Color(0xFFE05260);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()
        ..add(const RestoreSessionRequested()),
      child: MaterialApp(
        title: 'E-Store',
        debugShowCheckedModeBanner: false,
        theme: _buildAppTheme(),
        home: const AuthRouter(),
      ),
    );
  }

  ThemeData _buildAppTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 3,
        shadowColor: AppColors.primary.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.20),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        labelStyle: const TextStyle(
          color: AppColors.text,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.text,
        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.primary.withValues(alpha: 0.12),
      ),

      iconTheme: const IconThemeData(
        color: AppColors.primary,
      ),
    );
  }
}

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return RoleHomeScreen(
            user: state.user,
            onLogout: () {
              context.read<AuthBloc>().add(
                    const LogoutRequested(),
                  );
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
