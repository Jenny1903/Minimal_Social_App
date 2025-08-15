import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/my_button.dart';
import 'package:social_app/components/my_textfield.dart';
import 'package:social_app/helper/helper_fuctions.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //text collectors
 final TextEditingController emailController = TextEditingController();
 final TextEditingController passwordController = TextEditingController();

 //login method
 void login() async {
   showDialog(context: context,
       builder: (context) => const Center(
         child: CircularProgressIndicator(),
       ),
   );

   //try sign in
   try{
     await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);

     //pop loading circle
     if(context.mounted) Navigator.pop(context);
   }
   
   //display any error
   on FirebaseAuthException catch (e) {
    
     //pop loading circle
     Navigator.pop(context);
     displayMessageToUser(e.code, context);
     
   }

 }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),

               const SizedBox(height: 35),

                const Text(

                  "F E L L O",
                  style: TextStyle(fontSize: 20),
                ),

                const SizedBox(height:50),
                //email textField
                MyTextfield(
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController,
                ),

                const SizedBox(height:10),

                //password textfield
                MyTextfield(
                    hintText: "Password",
                    obscureText: true,
                    controller: passwordController,
                ),
                const SizedBox(height:10),

                //forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                   Text(
                     "Forgot Passoword?",
                   style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary),
                    ), //text
                  ],
                ),

                const SizedBox(height:10),
          // sign in here
                MyButton(
                    text: "Login",
                    onTap: login,
                ),

                const SizedBox(height:10),
                //don't have an account ? Register here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                    "Don't have an account? " ,
                        style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                        ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                          "Register Here",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                      ),
                    ),
                  ],
                ),
              ],
          ),
        )
      )
    );
  }
}
