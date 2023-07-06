import 'package:firebase_auth/firebase_auth.dart';

class CurrentUser {
  static User getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    return user!;
  }
}
