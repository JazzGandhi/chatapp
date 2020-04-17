import 'package:chatapp/ModelClasses/userInfo.dart';
import 'package:chatapp/Pages/homepage.dart';
import 'package:chatapp/Pages/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class PhoneAuthService{
  FirebaseAuth auth=FirebaseAuth.instance;
  checkIfLoggedIn(){

    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context,snapshot){
        if(snapshot.hasData)
          return HomePage();
        else
          return LoginPage();
      },
    );
  }
  signOut()
  {
    auth.signOut();
  }
  signIn(AuthCredential cred,context,Info obj){
      auth.signInWithCredential(cred).then((AuthResult val){
        if(val.user!=null){
          obj.uploadDataToDB();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
        else{
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("OTP seems to be wrong"),duration: Duration(milliseconds: 700),));

        }
      });
  }

  signInWithOTP(smsCode,verificationId,context,Info obj){
    print("PRINTING VERID "+verificationId);
    if(verificationId!="")
      signIn(PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: smsCode),context,obj);
  }
}