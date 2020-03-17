import 'package:chatapp/Others/PhoneNumAuthService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    PhoneAuthService().signIn(authCredential,context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //rgb(223,239,220)
          backgroundColor: Color.fromRGBO(205, 241, 248, 1),
          //rgb(80,106,254)
          title: Text("ChatApp",style: TextStyle(color: Color.fromRGBO(100, 96, 255, 1)),),
        ),
        body: Container(
          //rgb(205,241,248)rgb(196,196,233)
          color: Color.fromRGBO(235, 245, 255, 1) ,
          margin: EdgeInsets.only(left: 0,right: 10),
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Form(
                key: formkey,
                child: TextFormField(
                  decoration: InputDecoration(
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
                child: Text(error,style: TextStyle(color: Colors.red),),
              ),
              RaisedButton(
                child: Text("Verify number"),
                color: Colors.lightGreenAccent,
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
                          Text("Enter the code you received:"),
                          TextField(
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
                                child: Text("Verify Code"),
                                color: Colors.greenAccent,
                                onPressed: () {
                                  if (smsCode.length==6)
                                    PhoneAuthService().signInWithOTP(smsCode, verId,context);
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
