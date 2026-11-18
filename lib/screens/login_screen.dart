import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:estore_app/blocs/auth/auth_bloc.dart';
import 'package:estore_app/blocs/auth/auth_event.dart';
import 'package:estore_app/blocs/auth/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginView();
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  final _userCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  final _userCodeFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;

  static const Color primaryColor = Color(0xFF5B4BDB);
  static const Color secondaryColor = Color(0xFF9C6ADE);
  static const Color textColor = Color(0xFF292547);

  @override
  void dispose() {
    _userCodeController.dispose();
    _passwordController.dispose();
    _userCodeFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthLoading) return;

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    context.read<AuthBloc>().add(
      LoginRequested(
        userCode: _userCodeController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _moveToPassword() {
    FocusScope.of(context).requestFocus(_passwordFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF1EEFF),
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF7667E8),
                      Color(0xFFB49AEF),
                      Color(0xFFD7C8F7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(45),
                    bottomRight: Radius.circular(45),
                  ),
                ),
              ),

              Positioned(
                top: 65,
                right: -35,
                child: CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),

              Positioned(
                top: 180,
                left: -45,
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),

              Positioned(
                top: 300,
                right: 20,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // App branding
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'E-Store',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Everything you need, all in one place',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),

                        const SizedBox(height: 35),

                        // Login card
                        Card(
                          elevation: 10,
                          shadowColor: primaryColor.withValues(alpha: 0.18),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(26),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Welcome Back!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  const Text(
                                    'Sign in to continue shopping',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // User code
                                  const Text(
                                    'User Code',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  TextFormField(
                                    controller: _userCodeController,
                                    focusNode: _userCodeFocusNode,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onFieldSubmitted: (_) {
                                      _moveToPassword();
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Enter your user code',
                                      prefixIcon: const Icon(
                                        Icons.person_outline,
                                        color: primaryColor,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8F7FF),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter your user code';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 20),

                                  // Password
                                  const Text(
                                    'Password',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  TextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) {
                                      if (!isLoading) {
                                        _login();
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        color: primaryColor,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: secondaryColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8F7FF),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter your password';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 30),

                                  // Sign in button
                                  SizedBox(
                                    height: 54,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            primaryColor,
                                            secondaryColor,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              Colors.transparent,
                                          disabledForegroundColor:
                                              Colors.white70,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 23,
                                                width: 23,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Sign In',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Icon(
                                                    Icons.arrow_forward_rounded,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Welcome to E-Store',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Your shopping experience starts here.',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
