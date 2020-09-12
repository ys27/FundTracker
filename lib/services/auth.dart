import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthentication show User;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<FirebaseAuthentication.User> get user {
    return _auth.idTokenChanges();
  }

  Future register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await sendEmailVerification();
      return result.user;
    } catch (e) {
      return e.message;
    }
  }

  Future signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (!result.user.emailVerified) {
        return null;
      }
      return result.user;
    } catch (e) {
      return e.message;
    }
  }

  Future sendEmailVerification() async {
    await _auth.currentUser.sendEmailVerification();
  }

  Future sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return e.message;
    }
  }
}
