import 'package:helpdesk/features/auth/model/user_model.dart';

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final String message;
  final UserModel user;
  AuthSuccessState({required this.message, required this.user});
}

class AuthErrorState extends AuthState {
  final String errorMessage;
  AuthErrorState({required this.errorMessage});
}

class AuthPasswordVisibilityToggledState extends AuthState {
  final bool isPasswordHidden;
  AuthPasswordVisibilityToggledState(this.isPasswordHidden);
}

class AuthConfirmPasswordVisibilityToggledState extends AuthState {
  final bool isConfirmPasswordHidden;
  AuthConfirmPasswordVisibilityToggledState(this.isConfirmPasswordHidden);
}

class AuthRoleSelectedState extends AuthState {
  final UserRole role;
  AuthRoleSelectedState(this.role);
}

class AuthDepartmentSelectedState extends AuthState {
  final String department;
  AuthDepartmentSelectedState(this.department);
}

class AuthRememberMeToggledState extends AuthState {
  final bool rememberMe;
  AuthRememberMeToggledState(this.rememberMe);
}

class AuthLoggedOutState extends AuthState {}

class AuthProfileUpdatedState extends AuthState {
  final UserModel user;
  final String message;
  AuthProfileUpdatedState({required this.user, required this.message});
}

