import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
     final FirebaseAuth _auth=FirebaseAuth.instance;
     final FirebaseFirestore _firestore=FirebaseFirestore.instance;

     //signup
     Future<UserCredential>signUp({
      required String name,
      String? lastname,
      required String email,
      required String password,
      required int phonenumber,
     })async{
      final credential=
      await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
        );
        await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set({
          'firstname':name,
          'lastName':lastname,
          'phonenumber':phonenumber,
          'income':0,
          'expense':0,
          'totalBalance':0,
        });
        return credential;

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
