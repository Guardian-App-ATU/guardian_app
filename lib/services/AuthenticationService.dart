import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanged => _firebaseAuth.authStateChanges();

  Future<void> logOut() async {
    return await _firebaseAuth.signOut();
  }

  Future<void> deleteUser() async {
    return await _firebaseAuth.currentUser?.delete();
  }

  Future<UserCredential?> signUp(String username, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: username, password: password);
  }

  Future<UserCredential?> signIn(String username, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: username, password: password);
  }

  Future<UserCredential?> signInGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    OAuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

    return _firebaseAuth.signInWithCredential(authCredential);
  }
}
