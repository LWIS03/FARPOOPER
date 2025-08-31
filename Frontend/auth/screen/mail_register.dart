import 'package:farpooper_frontend/auth/screen/googel_login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../choose_home_dialog.dart';

class mailRegister extends StatelessWidget{

  var emailController = TextEditingController();
  var passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Padding(padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email"
              ),
            ),
            SizedBox(height: 25,),
            TextField(
              controller: passController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password"
              ),
              obscureText: true,
            ),
            SizedBox(height: 25,),
            ElevatedButton(onPressed: () {
              String mail = emailController.text.trim();
              String password = passController.text.trim();

              if(mail.isEmpty || password.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter All the fields")));
              }
              else{
                FirebaseAuth.instance.createUserWithEmailAndPassword(email: mail, password: password).then((value){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Register successfully")));
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ChooseHome()));
                });

              }

            },
                child: Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent )),
            SizedBox(height: 25,),
            InkWell(
              onTap: () {

                Colors.blue.shade800;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> GoogleLoginScreen()));
                
              },
              child: Text("Already have an account? Click Here",
                 style: TextStyle(color: Colors.blueAccent),)
            )
          ],
        ),
      ),
    );
    throw UnimplementedError();
  }
}