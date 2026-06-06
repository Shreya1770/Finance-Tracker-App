import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
     final FirebaseAuth _auth=FirebaseAuth.instance;

     //signup
     Future<UserCredential>signUp({
      required String email,
      required String password,
      String? lastname,
      required int phonenumber,
     })async{
      return await _auth.createUserWithEmailAndPassword(
        email: email,
         password: password
         );

     }

     //login
     Future<UserCredential>login({
      required email,
      required password,
     }) async{
      return await _auth.signInWithEmailAndPassword(
        email: email,
       password: password
       );
     }
     //signOut
     Future<void> logOut() async{
      await _auth.signOut();

     }
     //Reset Password Email
     Future<void>resetPassword(String email) async{
      await _auth.sendPasswordResetEmail(
        email: email,
        );
     }
     User? get currentUser=>_auth.currentUser;
}
