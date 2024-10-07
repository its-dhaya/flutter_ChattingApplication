import 'dart:developer'; // Import 'dart:developer' for the log function
import 'package:chattify/api/apis.dart';
import 'package:chattify/helper/dialog.dart';
import 'package:chattify/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  void _handlegooglebtn() {
    Dialogs.showProgressbar(context);
    _signInWithGoogle().then((user) async {
      if (user != null) {
        log('User: ${user.user}');
        log('UserAdditionalInfo: ${user.additionalUserInfo}');
         if((await APIs.userExists())){
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Homepage()));
         }else{
          await APIs.createUser().then((value){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>Homepage()));
          });
         }
        

        // Navigate to the Homepage if the user is authenticated
        
      } 
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        log('Google sign-in canceled by user.');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('Error during sign in: $e');
      Dialogs.showSnackbar(context, 'Something went wrong(Check Internet)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Welcome to CHATTIFY'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: _isAnimate ? mq.height * .15 : -mq.width * .5,
            left: mq.width * .28,
            duration: Duration(seconds: 1),
            width: mq.width * .4,
            child: Image.asset('assets/chaticon.png'),
          ),
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.shade700,
                  shape: StadiumBorder()),
              onPressed: () {
                _handlegooglebtn();
              },
              icon: Image.asset(
                'assets/google.png',
                color: Colors.white,
                width: 50,
              ),
              label: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  children: [
                    TextSpan(text: 'Sign in with '),
                    TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
