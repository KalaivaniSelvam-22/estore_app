import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable{
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String userCode;
  final String password;

  const LoginRequested({required this.userCode, required this.password});

  @override
  // TODO: implement props
  List<Object?> get props => [userCode, password];
}

class LogoutRequested extends AuthEvent{
  const LogoutRequested(); 
}
class RestoreSessionRequested extends AuthEvent {
  const RestoreSessionRequested();
}