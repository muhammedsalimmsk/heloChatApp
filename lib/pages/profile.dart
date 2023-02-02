

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/helper/edit_name.dart';
import 'package:untitled/service/database_service.dart';
import 'package:untitled/widgets/drawer.dart';
import 'package:untitled/widgets/widget.dart';

import '../helper/helper_function.dart';
import '../main.dart';
import '../service/auth_service.dart';


String profilePic="";

class profile extends StatefulWidget {
  const profile({Key? key}) : super(key: key);

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  AuthService authService = AuthService();
  String userName = "";
  String email = "";
  User? user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailfromSF().then((value) {
      setState(() {
        email = value!;
      });
      user=FirebaseAuth.instance.currentUser;
    });
    await HelperFunctions.getUserNamefromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }
  void pickUploadImage()async{
    final image= await ImagePicker().pickImage(
        source:ImageSource.gallery,
        imageQuality: 75);
    await ref.putFile(File(image!.path));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: const Text('',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27)),
      ),
      drawer: const Drawer_Custom(),
      body: Container(
        //padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: (){
                pickUploadImage();
              },
              child:profilePic==""? Icon(
                Icons.account_circle_rounded,
                size: 200,
                color: Colors.grey[700],
              ):
              circleProfilePic(),
            ),
            const SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: (){
                nextScreen(context, EditFullName(userName: userName,uid:user!.uid,));
              },
              child: ListTile(
                title: Text(userName,
                    style:const TextStyle(color:Colors.black,fontSize: 25,fontWeight:FontWeight.bold),),
                subtitle:const Text(
                    "Tap to change full name",
                    style: TextStyle(fontSize: 17,),),
              ),
            ),
            ListTile(
              title: Text(
                email,
                style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
              ),
              subtitle:const Text(
                "Email",
                style: TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
