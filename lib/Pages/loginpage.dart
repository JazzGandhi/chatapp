import 'dart:io';

import 'package:chatapp/ModelClasses/userInfo.dart';
import 'package:chatapp/Others/PhoneNumAuthService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String phoneNum="", smsCode = "", verId = "",error=" + is not included in country code";
  bool isDisabled = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final formkey=GlobalKey<FormState>();
  bool isCountryCodeProper=true;

  _verificationComplete(AuthCredential authCredential, BuildContext context) {
    var obj=new Info(username: username,phoneNo:phoneNum,assetImg: "assets/images/"+lis[val&6],imgFile: imgFile);
    PhoneAuthService().signIn(authCredential,context,obj);
    //navigateToHomeScreen(context);
  }

  _smsCodeSent(String verificationId, List<int> code) {
    // set the verification code so that we can use it to log the user in
    verId = verificationId;
    print("verID:"+verId);
  }

  _verificationFailed(AuthException authException, BuildContext context) {
    final snackBar = SnackBar(
        content:
        Text("Exception!! message:" + authException.message.toString()));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    this.verId = verificationId;
  }

  verifyNum(BuildContext context) async {

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNum,
        timeout: Duration(minutes: 1),

        codeAutoRetrievalTimeout: (verificationId) =>
            _codeAutoRetrievalTimeout(verificationId),

        verificationCompleted: (authCredential) =>
            _verificationComplete(authCredential, context),

        verificationFailed: (authException) =>
            _verificationFailed(authException, context),

        // called when the SMS code is sent
        codeSent: (verificationId, [code]) =>
            _smsCodeSent(verificationId, [code]));
  }


  File imgFile;
  final formKey = GlobalKey<FormState>();
  SharedPreferences pref;
  bool isProfileCreated = false;
  String username;
  final lis = [
    "profile1.png",
    "profile2.png",
    "profile3.png",
    "profile4.png",
    "profile5.png",
    "profile6.png"
  ];
  int val = 0;
  double width;

  Widget img() {
    if(imgFile==null){
      return Container(
        width: 250,
        height: 250,
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          child: Image.asset(
            "assets/images/" + lis[val % 6],
          ) ,
        ),
      );
    }
    else{
      return Container(
        width: 250,
        height: 250,
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          child: Image.file(
            imgFile,
          ),
        ),
      );
    }
  }

  addToDb() {
    print(username);
  }

  uploadGallery() async{
    var img=await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imgFile=img;
    });
  }

  uploadCamera() async{
    var img=await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      imgFile=img;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(40, 49, 59, 1),
        appBar: AppBar(
          //rgb(223,239,220)
          backgroundColor: Color.fromRGBO(205, 241, 248, 1),
          //rgb(80,106,254)
          title: Text("ChatApp",style: TextStyle(color: Color.fromRGBO(100, 96, 255, 1)),),
        ),
        body: Container(
          //rgb(205,241,248)rgb(196,196,233)
          margin: EdgeInsets.only(left: 0,right: 10),
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Text("Your Profile:", style: TextStyle(
                  fontSize: 25, color: Color.fromRGBO(114, 133, 165, 1)),),
              Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.1,
                  child: Text(""),
                ),
              ),
              Flexible(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: img(),
                ),
              ),
              Visibility(
                visible: imgFile==null,
                child: FlatButton(
                  onPressed: () {
                    setState(() {
                      val += 1;
                    });
                  },
                  child: Text("CHANGE",style: TextStyle(color: Colors.white),),
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: Text("Select from Gallery"),
                    onPressed: ()=>uploadGallery(),
                  ),
                  FlatButton(
                    child: Text("Open Camera"),
                    onPressed: ()=>uploadCamera(),
                  ),
                  RaisedButton(
                    color: Colors.lightBlueAccent,
                    child: Text("Delete"),
                    onPressed: (){
                      setState(() {
                        imgFile=null;
                      });
                    },
                  ),
                ],
              ),
              Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.1,
                ),
              ),
              Form(
                key: formkey,
                child: TextFormField(
                  style: TextStyle(color: Colors.lightBlueAccent),
                  decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.lightBlueAccent),
                      labelText: "Phone number",
                      hintText: "Enter country code and number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      icon: isDisabled ? Icon(Icons.phone):Icon(Icons.perm_phone_msg)),
                  onSaved: (val){
                    this.phoneNum=val;
                  },
                  validator: (val){
                    if(val.length<8){
                      setState(() {
                        isCountryCodeProper=true;
                        isDisabled=true;
                      });
                      return "Number seems to be wrong";
                    }
                    else if(!val.contains("+") ) {
                      setState(() {
                        isCountryCodeProper=false;
                        isDisabled=true;
                      });
                      return "";
                    }
                    else{
                      setState(() {
                        isCountryCodeProper=true;
                      });
                      return null;
                    }
                  },
                ),
              ),
//          TextField(
//            decoration: InputDecoration(
//                labelText: "Phone number",
//                hintText: "Enter country code and number",
//                border: OutlineInputBorder(),
//                icon: Icon(Icons.phone)),
//            onChanged: (val) {
//              this.phoneNum = val;
//            },
//          ),
              Visibility(
                visible: !isCountryCodeProper,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Text(error,style: TextStyle(color: Colors.lightBlueAccent),),
              ),
              RaisedButton(
                child: Text("Verify number"),
                color: Colors.green,
                onPressed: () {
                  //print("YES BITCHES" + phoneNum);
                  if(formkey.currentState.validate())
                  {
                    formkey.currentState.save();
                    setState(() {
                      isDisabled = false;
                    });
                    verifyNum(context);
                  }
                },
              ),
              Visibility(
                  visible: !isDisabled,
                  child: Builder(
                    builder: (context) {
                      return Column(
                        children: <Widget>[
                          SizedBox(
                            child: Text("\n\n"),
                          ),
                          Text("Enter the code you received:",style: TextStyle(color: Colors.lightBlueAccent),),
                          TextField(
                            style: TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Enter Code",
                              hintText: smsCode,
                              //icon: Icon(Icons.)
                            ),
                            onChanged: (val) {
                              this.smsCode = val;
                              //print("THIS IS smscode: "+val);
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: RaisedButton(
                                child: Text("Verify Code",style: TextStyle(color: Colors.lightBlueAccent),),
                                color: Colors.greenAccent,
                                onPressed: () {
                                  if (smsCode.length==6){
                                    var obj=new Info(username: username,phoneNo:phoneNum,assetImg: "assets/images/"+lis[val&6],imgFile: imgFile);
                                    PhoneAuthService().signInWithOTP(smsCode, verId,context,obj);
                                  }
                                  else
                                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("OTP seems to bee wrong"),duration: Duration(milliseconds: 700)));
                                }
                            ),
                          ),
                        ],

                      );
                    },
                  )
              )
            ],
          ),
        )
    );
  }
}
