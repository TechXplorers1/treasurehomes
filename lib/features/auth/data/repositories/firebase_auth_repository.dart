import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserEntity> createUserByAdmin(
    String name,
    String email,
    String password,
    String phoneNumber,
    UserRole role,
  ) async {
    FirebaseApp? secondaryApp;
    try {
      // 1. Initialize a secondary Firebase App
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      // 2. Create the user in Firebase Auth using the secondary app
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user in Firebase Auth');
      }

      // 3. Update Display Name (optional but good practice)
      await user.updateDisplayName(name);

      // 4. Create the user document in Firestore (using the MAIN app's Firestore)
      // We use the UID from the newly created user
      final userEntity = UserEntity(
        id: user.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'role': role.name, // Store role as string
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userEntity;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    } finally {
      // 5. Delete the secondary app instance to clean up
      await secondaryApp?.delete();
    }
  }

  @override
  Future<UserEntity> signUp(String name, String email, String password) async {
    try {
      // Create user in Firebase Authentication
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Update Firebase Auth display name
      await user.updateDisplayName(name);

      // Create user document in Firestore
      final userEntity = UserEntity(
        id: user.uid,
        email: email,
        name: name,
        role: UserRole.customer,
      );

      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': email,
        'name': name,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userEntity;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Login failed');
      }

      // Fetch user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        // Force admin role for specific email
        UserRole role = _parseUserRole(data['role'] ?? 'customer');
        if (email == 'admin@gmail.com') {
          role = UserRole.admin;
        }

        return UserEntity(
          id: user.uid,
          email: user.email ?? '',
          name: data['name'] ?? user.displayName ?? 'User',
          phoneNumber: data['phoneNumber'],
          role: role,
        );
      }

      // Fallback if user doc doesn't exist
      // Force admin role for specific email
      UserRole role = UserRole.customer;
      if (email == 'admin@gmail.com') {
        role = UserRole.admin;
      }

      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'User',
        role: role,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      // Fetch user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        // Force admin role for specific email
        UserRole role = _parseUserRole(data['role'] ?? 'customer');
        if (user.email == 'admin@gmail.com') {
          role = UserRole.admin;
        }

        return UserEntity(
          id: user.uid,
          email: user.email ?? '',
          name: data['name'] ?? user.displayName ?? 'User',
          phoneNumber: data['phoneNumber'],
          role: role,
        );
      }

      // Fallback
      // Force admin role for specific email
      UserRole role = UserRole.customer;
      if (user.email == 'admin@gmail.com') {
        role = UserRole.admin;
      }

      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'User',
        role: role,
      );
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'user-disabled':
        return 'User account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'provider':
        return UserRole.provider;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }
}
