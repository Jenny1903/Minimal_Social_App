import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/my_button.dart';
import 'package:social_app/components/my_textfield.dart';
import '../helper/helper_fuctions.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.onTap});
  final void Function()? onTap;


  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();


  //Register method
  void registerUser() async {
    
    //show loading circle
    showDialog(context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
    );

    //make sure password match
    if (passwordController.text != confirmPasswordController.text){
      //pop loading circle
      Navigator.pop(context);

      //show little error message to user
      displayMessageToUser("Passwords Don't Match", context);
    }
    //if passwords do match
    else{
      //try creating the user
      try{
        //create the user
        UserCredential? userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text);

        //create a user document and add to firestore
        await createUserDocument(userCredential);

        //pop loading circle
        if(context.mounted) {
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        //pop the loading circle
        Navigator.pop(context);

        //display the error message
        displayMessageToUser(e.code,context);
      }
    }
  }

 //create a user document and collect them in firestore
  Future<void>  createUserDocument(UserCredential? userCredential) async{
    if(userCredential !=null && userCredential.user !=null){

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email' : userCredential.user!.email,
        'username': usernameController.text,
      });
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
                    "M I N I M A L",
                    style: TextStyle(fontSize: 20),
                  ),

                  const SizedBox(height:50),

                  //username textField
                  MyTextfield(
                    hintText: "Username",
                    obscureText: false,
                    controller: usernameController,
                  ),

                  const SizedBox(height:10),

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

                  //confirm password textfield
                  MyTextfield(
                    hintText: "Confirm Password",
                    obscureText: true,
                    controller: confirmPasswordController,
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

                  // register button
                  MyButton(
                    text: "Register",
                    onTap: registerUser,
                  ),

                  const SizedBox(height:10),
                  //don't have an account ? Register here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? " ,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Login Here",
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
