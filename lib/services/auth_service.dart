import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _createUserDoc(User user) async {
    final doc = _db.collection('users').doc(user.uid);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? 'User',
        'createdAt': FieldValue.serverTimestamp(),
        'totalPoints': 0,
      });
    }
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _createUserDoc(cred.user!);
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await _createUserDoc(cred.user!);
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      await _createUserDoc(cred.user!);
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Email already in use.';
      case 'wrong-password': return 'Wrong password.';
      case 'user-not-found': return 'No user found with this email.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'invalid-email': return 'Invalid email address.';
      default: return 'Authentication failed. Please try again.';
    }
  }
}