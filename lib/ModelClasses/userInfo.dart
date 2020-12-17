import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Info{
  Info({this.username,this.phoneNo,this.docID,this.assetImg,this.imgFile,this.url});
  String username;
  String phoneNo;
  String docID;
  String assetImg;
  String url;
  File imgFile;
  final String userData="username";
  final String userPhoneData="phoneNum";
  final String docData="docID";
  final String assetImgData="assetImg";
  final String imgurlData="imgURL";
  uploadDataToDB() async{
      if(imgFile!=null){
        try{
          Reference ref= FirebaseStorage.instance.ref().child("profile/$username");
          TaskSnapshot upload= await ref.putFile(imgFile);
          url=await upload.ref.getDownloadURL();
          imgFile=null;//database khaali rakhna hai mereko
          var docRef= FirebaseFirestore.instance.collection("USERS").doc();
          docID=docRef.id;
          await docRef.set({ userData:username , userPhoneData:phoneNo , docData:docID , assetImgData:null , imgurlData:url } );
          SharedPreferences pref=await SharedPreferences.getInstance();
          pref.setString(docData, docID);//so i can access user data from firestore anywhere in app
        }
        on Exception catch(e){
          print(e);
        }
      }
      else{
        //asset img dp rakhna hai baap ko
        var docRef= FirebaseFirestore.instance.collection("USERS").doc();
        docID=docRef.id;
        await docRef.set({ userData:username , userPhoneData:phoneNo , docData:docID , assetImgData: assetImg , imgurlData:null } );
        SharedPreferences pref=await SharedPreferences.getInstance();
        pref.setString(docData, docID);
      }
  }
}