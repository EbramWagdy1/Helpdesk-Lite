import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:helpdesk/core/database/cache/cache_helper.dart';
import 'package:helpdesk/core/database/cache/cache_keys.dart';
import 'package:helpdesk/core/services/firebase_service.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in cancelled');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;
    if (user == null) {
      throw Exception('Google sign in failed: User is null.');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) {
      final newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? googleUser.displayName ?? 'Google User',
        email: user.email ?? googleUser.email,
        phone: user.phoneNumber ?? '',
        avatarUrl: user.photoURL ?? googleUser.photoUrl,
        role: UserRole.employee,
        department: 'General',
        isVerified: false,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      await _cacheUserSession(newUser);
      return newUser;
    }

    final userModel = UserModel.fromMap(doc.data()!, user.uid);
    if ((userModel.avatarUrl == null || userModel.avatarUrl!.isEmpty) && (user.photoURL != null || googleUser.photoUrl != null)) {
      final photo = user.photoURL ?? googleUser.photoUrl;
      await _firestore.collection('users').doc(user.uid).update({'avatarUrl': photo});
    }
    await _cacheUserSession(userModel);
    return userModel;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? user = credential.user;
    if (user == null) {
      throw Exception('Login failed: User not found.');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) {
      // Fallback: create default user profile if none exists
      final newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? email.split('@').first,
        email: email,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      await _cacheUserSession(newUser);
      return newUser;
    }

    final userModel = UserModel.fromMap(doc.data()!, user.uid);
    await _cacheUserSession(userModel);
    return userModel;
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    required String department,
  }) async {
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? user = credential.user;
    if (user == null) {
      throw Exception('Sign up failed: User could not be created.');
    }

    await user.updateDisplayName(name);

    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      department: department,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
    await _cacheUserSession(userModel);
    return userModel;
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      final userModel = UserModel.fromMap(doc.data()!, user.uid);
      await _cacheUserSession(userModel);
      return userModel;
    }
    return null;
  }

  Stream<UserModel?> streamCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        final userModel = UserModel.fromMap(doc.data()!, doc.id);
        _cacheUserSession(userModel);
        return userModel;
      }
      return null;
    });
  }

  /// Instantly returns cached user data from local storage with zero delay
  UserModel? getCachedUser() {
    final uid = CacheHelper.getString(key: CacheKeys.userId);
    final email = CacheHelper.getString(key: CacheKeys.userEmail);
    final name = CacheHelper.getString(key: CacheKeys.userName);
    final roleStr = CacheHelper.getString(key: CacheKeys.userRole);
    final department = CacheHelper.getString(key: CacheKeys.userDepartment) ?? 'General';
    final phone = CacheHelper.getString(key: CacheKeys.userPhone) ?? '';
    final avatarUrl = CacheHelper.getString(key: CacheKeys.userPhotoUrl);
    final isVerified = CacheHelper.getBool(key: CacheKeys.userIsVerified) ?? false;

    if (uid != null && email != null && name != null && roleStr != null) {
      return UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        department: department,
        avatarUrl: avatarUrl,
        role: UserRole.values.firstWhere(
          (e) => e.name == roleStr,
          orElse: () => UserRole.employee,
        ),
        isVerified: isVerified,
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  Future<UserModel> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String department,
    String? photoUrl,
  }) async {
    final Map<String, dynamic> updateData = {
      'name': name.trim(),
      'phone': phone.trim(),
      'department': department,
    };
    if (photoUrl != null) {
      updateData['avatarUrl'] = photoUrl;
    }

    await _firestore.collection('users').doc(uid).update(updateData);
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name.trim());
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await user.updatePhotoURL(photoUrl);
      }
    }

    final updatedDoc = await _firestore.collection('users').doc(uid).get();
    final updatedUser = UserModel.fromMap(updatedDoc.data()!, uid);
    await _cacheUserSession(updatedUser);
    return updatedUser;
  }

  Future<List<UserModel>> getSupportAgents() async {
    final query = await _firestore
        .collection('users')
        .where('role', whereIn: ['agent', 'manager'])
        .get();

    return query.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<UserModel>> streamSupportAgents() {
    return _firestore
        .collection('users')
        .where('role', whereIn: ['agent', 'manager'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<UserModel>> streamAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateUserRole({
    required String uid,
    required UserRole newRole,
    bool? isVerified,
    String? department,
  }) async {
    try {
      final data = <String, dynamic>{
        'role': newRole.name,
      };
      if (isVerified != null) {
        data['isVerified'] = isVerified;
      } else if (newRole == UserRole.agent) {
        data['isVerified'] = true;
      } else if (newRole == UserRole.manager) {
        data['isVerified'] = true;
      }
      if (department != null) {
        data['department'] = department;
      }
      await _firestore.collection('users').doc(uid).update(data);
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Permission denied to update user role.');
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  Future<void> updateAgentVerification({
    required String agentUid,
    required bool isVerified,
  }) async {
    try {
      await _firestore.collection('users').doc(agentUid).update({
        'isVerified': isVerified,
      });
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Permission denied to update agent verification.');
    } catch (e) {
      throw Exception('Failed to update agent verification: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await CacheHelper.saveData(key: CacheKeys.isLoggedIn, value: false);
    await CacheHelper.removeData(key: CacheKeys.userId);
    await CacheHelper.removeData(key: CacheKeys.userEmail);
    await CacheHelper.removeData(key: CacheKeys.userName);
    await CacheHelper.removeData(key: CacheKeys.userPhone);
    await CacheHelper.removeData(key: CacheKeys.userRole);
    await CacheHelper.removeData(key: CacheKeys.userDepartment);
    await CacheHelper.removeData(key: CacheKeys.userPhotoUrl);
    await CacheHelper.removeData(key: CacheKeys.userIsVerified);
  }

  Future<void> _cacheUserSession(UserModel user) async {
    await CacheHelper.saveData(key: CacheKeys.isLoggedIn, value: true);
    await CacheHelper.saveData(key: CacheKeys.isVisited, value: true);
    await CacheHelper.saveData(key: CacheKeys.userId, value: user.uid);
    await CacheHelper.saveData(key: CacheKeys.userEmail, value: user.email);
    await CacheHelper.saveData(key: CacheKeys.userName, value: user.name);
    await CacheHelper.saveData(key: CacheKeys.userPhone, value: user.phone);
    await CacheHelper.saveData(key: CacheKeys.userRole, value: user.role.name);
    await CacheHelper.saveData(key: CacheKeys.userDepartment, value: user.department);
    await CacheHelper.saveData(key: CacheKeys.userPhotoUrl, value: user.avatarUrl);
    await CacheHelper.saveData(key: CacheKeys.userIsVerified, value: user.isVerified);
  }
}
