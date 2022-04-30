import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../repositories/firestore_repository.dart';

class GoogleSignInProvider extends ChangeNotifier {
  static final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  get user => _user;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      FirestoreRepository.user = FirebaseAuth.instance.currentUser;
      FirestoreRepository.createUser();
    } catch (e, s) {
      if (kDebugMode) {
        print(e);
      }
      if (kDebugMode) {
        print(s);
      }
    }

    notifyListeners();
  }

  Future logOut() async {
    //await googleSignIn.disconnect();
    await googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
    FirestoreRepository.erContactList = [];
    FirestoreRepository.fallDetectList = [];
    FirestoreRepository.user = null;
  }
}
