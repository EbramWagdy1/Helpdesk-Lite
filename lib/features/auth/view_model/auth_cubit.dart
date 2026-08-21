import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpdesk/core/errors/error_handler.dart';
import 'package:helpdesk/core/services/service_locator.dart';
import 'package:helpdesk/features/auth/data/auth_repository.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';
import 'package:helpdesk/features/auth/view_model/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<UserModel?>? _userProfileSubscription;

  AuthCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? sl<AuthRepository>(),
        super(AuthInitialState()) {
    // 1. Instantly populate currentUser from local cache (0ms delay)
    currentUser = _authRepository.getCachedUser();
    // 2. Fetch latest data from Firestore & attach real-time live stream
    checkCurrentUser();
    listenToUserProfileUpdates();
  }

  void listenToUserProfileUpdates() {
    _userProfileSubscription?.cancel();
    _userProfileSubscription = _authRepository.streamCurrentUserProfile().listen((user) {
      if (user != null) {
        currentUser = user;
        emit(AuthSuccessState(message: 'User profile synchronized', user: user));
      }
    });
  }

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  UserModel? currentUser;
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool rememberMe = true;
  UserRole selectedRole = UserRole.employee;
  String selectedDepartment = 'IT & Systems';

  final List<String> departments = [
    'IT & Systems',
    'Human Resources',
    'Operations',
    'Finance & Payroll',
    'Sales & Marketing',
    'Customer Support',
    'Facilities',
    'General',
  ];

  void selectRole(UserRole role) {
    selectedRole = role;
    emit(AuthRoleSelectedState(role));
  }

  void selectDepartment(String department) {
    selectedDepartment = department;
    emit(AuthDepartmentSelectedState(department));
  }

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    emit(AuthPasswordVisibilityToggledState(isPasswordHidden));
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden = !isConfirmPasswordHidden;
    emit(AuthConfirmPasswordVisibilityToggledState(isConfirmPasswordHidden));
  }

  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
    emit(AuthRememberMeToggledState(rememberMe));
  }

  Future<UserModel?> checkCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUserProfile();
      if (user != null) {
        currentUser = user;
        emit(AuthSuccessState(message: 'User profile loaded', user: user));
      } else {
        currentUser = null;
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String department,
    String? photoUrl,
  }) async {
    if (currentUser == null) return;
    emit(AuthLoadingState());

    try {
      final updated = await _authRepository.updateUserProfile(
        uid: currentUser!.uid,
        name: name,
        phone: phone,
        department: department,
        photoUrl: photoUrl,
      );

      currentUser = updated;
      emit(AuthProfileUpdatedState(
        user: updated,
        message: 'Profile updated successfully!',
      ));
    } catch (e) {
      emit(AuthErrorState(errorMessage: 'Failed to update profile: $e'));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoadingState());

    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      currentUser = user;
      listenToUserProfileUpdates();

      emit(AuthSuccessState(
        message: 'Welcome back, ${user.name}!',
        user: user,
      ));
    } catch (e) {
      emit(AuthErrorState(errorMessage: _formatAuthError(e)));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoadingState());

    try {
      final user = await _authRepository.signInWithGoogle();
      currentUser = user;
      listenToUserProfileUpdates();

      emit(AuthSuccessState(
        message: 'Welcome, ${user.name}!',
        user: user,
      ));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.toLowerCase().contains('cancelled') || msg.toLowerCase().contains('canceled')) {
        emit(AuthInitialState()); // Silently return to initial state if user cancelled
      } else {
        emit(AuthErrorState(errorMessage: _formatAuthError(e)));
      }
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    emit(AuthLoadingState());

    try {
      final user = await _authRepository.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: selectedRole,
        department: selectedDepartment,
      );

      currentUser = user;
      listenToUserProfileUpdates();

      emit(AuthSuccessState(
        message: 'Account created successfully!',
        user: user,
      ));
    } catch (e) {
      emit(AuthErrorState(errorMessage: _formatAuthError(e)));
    }
  }

  Future<void> logout() async {
    _userProfileSubscription?.cancel();
    _userProfileSubscription = null;
    await _authRepository.signOut();
    currentUser = null;
    emit(AuthLoggedOutState());
  }

  @override
  Future<void> close() {
    _userProfileSubscription?.cancel();
    return super.close();
  }

  String _formatAuthError(dynamic error) {
    return ErrorHandler.getErrorMessage(error);
  }
}
