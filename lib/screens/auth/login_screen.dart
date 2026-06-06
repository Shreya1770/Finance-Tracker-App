import 'package:expense_tracker/core/theme.dart';
import 'package:expense_tracker/screens/auth/forget_screen.dart';
import 'package:expense_tracker/screens/auth/signUp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget{
  const LoginScreen({super.key,});
  
  @override
  ConsumerState<LoginScreen> createState() =>_LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email=TextEditingController();
  final password=TextEditingController();
  final formkey=GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final isLoading=ref.watch(authProvider);
    bool isPaswordHidden=true;

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: const Offset(0, -150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset("assets/images/logo.png",
                    height: MediaQuery.of(context).size.height*0.40,
                    fit: BoxFit.cover,
                    ),
                  ),
                ),
                // SizedBox(height: 10,
                // ),
                
                Transform.translate(
                  offset: const Offset(0, -140),
                  child: Center(
                    child: Text("Your Smart Finance Tracker",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 22,
                    ),),
                  ),
                ),
                SizedBox(height: 20,),
                Form(
                  key: formkey,
                  child: Transform.translate(
                    offset: const Offset(0, -80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Email",
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.textPrimary,
                        ),),
                      ),
                      SizedBox(height: 5,),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 2.0,horizontal: 30.0),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(20),                  
                        ),
                        child: TextFormField(
                          validator: (value) {
                            if(value==null || value.isEmpty || !value.contains("@")){
                              return "Enter Valid Email";
                            }
                            return null;
                          },
                          controller: email,
                          decoration: InputDecoration(
                            labelText: "your@email.com",
                            fillColor: AppColors.textPlaceholder,
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Password",
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.textPrimary,
                        ),),
                      ),
                      SizedBox(height: 5,),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 2.0,horizontal: 30.0),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(20),                  
                        ),
                        child: TextFormField(
                          validator: (value) {
                            if(value==null || value.isEmpty){
                              return "Enter Valid Password";
                            }
                            if(value.length>8){
                              return "Password Length Should not exceed 8 Characters";
                            }
                            return null;
                          },
                          controller: password,
                          obscureText: isPaswordHidden,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(icon: Icon(
                              isPaswordHidden
                              ?Icons.visibility_off
                              :Icons.visibility,
                              ),
                              onPressed: (){
                                setState(() {
                                  isPaswordHidden=!isPaswordHidden;
                                });
                              },),
                            fillColor: const Color.fromARGB(15, 7, 7, 7),
                          ),
                        ),
                      ),
                       SizedBox(height: 20,),
                       ElevatedButton(onPressed: isLoading?
                       null
                       :()async{
                        await ref
                                 .read(authProvider.notifier)
                                 .login(email.text.trim(),
                                  password.text.trim());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Login Successfully")),
                                  );
                       }, child: isLoading?
                       CircularProgressIndicator()
                       :Text("Login")),
                       TextButton(onPressed:(){
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>SignupScreen()));
                       } ,
                        child: Text("Create Account"),),
                         TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                ),
              ),
                    
                    ],
                    ),
                  ))
                    
              ],
            ),
          ),
      ]),
      
    );
  
  }
}