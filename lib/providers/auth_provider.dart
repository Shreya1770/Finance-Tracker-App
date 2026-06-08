import 'package:expense_tracker/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authServiceProvider=Provider<AuthService>((ref)=>AuthService());

class AuthNotifier extends StateNotifier<bool>{
  final AuthService authService;
  AuthNotifier(this.authService):super(false);

  //state=loading
  Future<void> login(
    String email,
    String password,
  )async{
    try{
      state=true;
      await authService.login(email: email, password: password);
    }
    finally{
      state=false;
    }
  }

  Future<void> signUp(
    String email,
    String password,
    int phonenumber,
    String? lastname,
  )async{
    try{
      state=true;
    await authService.signUp(
      email: email,
       password: password,
        phonenumber: phonenumber,
        lastname: lastname,
        );
    }
    finally{
      state=false;
    }
  }
  Future<void> forgotpassword(
    String email,
  )async{
    try{
      state=true;
      await authService.resetPassword(email);
    }
    finally{
      state=false;
    }
  }
}
  final authProvider=StateNotifierProvider<AuthNotifier,bool>((ref){
    return AuthNotifier(ref.read(authServiceProvider),);
  });

  final authStateProvider=StreamProvider((ref){
    return FirebaseAuth.instance.authStateChanges();
  });
  
