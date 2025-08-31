import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn.instance;

  Future<bool> signInWithGoogle() async {
    try {
      await googleSignIn.initialize(
        serverClientId: '5189700141-jsteacugade3bs0p7i0ckikr24vbfuek.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.authenticate();

      if (googleSignInAccount == null) {
        return false;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
      );

      await auth.signInWithCredential(authCredential);
      return true;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Error general: $e');
      return false;
    }
  }

  Future<void> googleSignOut() async {
    await auth.signOut();
    await googleSignIn.signOut();
  }
}
