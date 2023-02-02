import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/pages/home_page.dart';
import 'package:untitled/pages/settings.dart';
import '../helper/helper_function.dart';
import '../pages/auth/login_page.dart';
import '../pages/profile.dart';
import '../service/auth_service.dart';
import 'widget.dart';
class Drawer_Custom extends StatefulWidget {
  const Drawer_Custom({Key? key}) : super(key: key);



  @override
  State<Drawer_Custom> createState() => _Drawer_CustomState();
}

class _Drawer_CustomState extends State<Drawer_Custom> {
  AuthService authService = AuthService();

  String userName = "";

  String email = "";

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
    });
    await HelperFunctions.getUserNamefromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50),
            color:Theme.of(context).primaryColor,
            child:Column(
              children: [
                profilePic==""?Icon(
                  Icons.account_circle_rounded,
                  size: 150,
                  color:Colors.white,
                ):
                circleProfilePic(),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  userName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ) ,
          ),
          const Divider(
            height: 2,
          ),
          DrawerList(
              text: "home".tr,
              icon: Icons.home,
              onTap:  (){
                nextScreen(context,const HomePage());
              }),
          DrawerList(
            text: 'profile'.tr,
            icon: Icons.person,
            onTap: () {
              nextScreen(context,const profile());
            },
          ),
          DrawerList(
              text: "settings".tr, icon: Icons.settings, onTap: () {
            nextScreen(context,settings_page());
          }),
          DrawerList(
              text: "logout".tr,
              icon: Icons.exit_to_app,
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("logout".tr),
                        content: Text("want logout".tr),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("cancel".tr)),
                          TextButton(
                              onPressed: () {
                                authService.signOut().whenComplete(() {
                                  nextScreenReplace(
                                      context, const LoginPage());
                                });
                              },
                              child:Text("continue".tr))
                        ],
                      );
                    });
              })
        ],
      ),
    );
  }
}
