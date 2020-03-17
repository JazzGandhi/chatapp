import 'package:chatapp/Others/PhoneNumAuthService.dart';
import 'package:chatapp/Pages/contacts_listpage.dart';
import 'package:chatapp/Pages/loginpage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          RaisedButton(
              child: Text("SIGNOUT"),
              onPressed: () {
                PhoneAuthService().signOut();
                Navigator.of(context).push(MaterialPageRoute
                  (builder: (context) => LoginPage()));
              }
          ),
          FlatButton(
            child: Text("NEXT"),
            onPressed: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ContactPermission())),
          )
        ],
      ),
    );
  }
}
