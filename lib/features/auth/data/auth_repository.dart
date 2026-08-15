import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpdesk/core/database/cache/cache_helper.dart';
import 'package:helpdesk/core/database/cache/cache_keys.dart';
import 'package:helpdesk/core/services/firebase_service.dart';
import 'package:helpdesk/features/auth/model/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

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
      return UserModel.fromMap(doc.data()!, user.uid);
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
      updateData['photoUrl'] = photoUrl;
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
    await CacheHelper.saveData(key: CacheKeys.isLoggedIn, value: false);
    await CacheHelper.removeData(key: CacheKeys.userEmail);
    await CacheHelper.removeData(key: CacheKeys.userName);
    await CacheHelper.removeData(key: 'user_role');
    await CacheHelper.removeData(key: 'user_id');
  }

  Future<void> _cacheUserSession(UserModel user) async {
    await CacheHelper.saveData(key: CacheKeys.isLoggedIn, value: true);
    await CacheHelper.saveData(key: CacheKeys.isVisited, value: true);
    await CacheHelper.saveData(key: CacheKeys.userEmail, value: user.email);
    await CacheHelper.saveData(key: CacheKeys.userName, value: user.name);
    await CacheHelper.saveData(key: 'user_role', value: user.role.name);
    await CacheHelper.saveData(key: 'user_id', value: user.uid);
  }
}
