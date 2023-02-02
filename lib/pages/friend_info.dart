import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/widget.dart';
class FriendInfo extends StatelessWidget {
  final String memberName;
  const FriendInfo({Key? key,
  required this.memberName,}) : super(key: key);
  final String profilePic="";

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
      body: Container(
        //padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              profilePic==""? Icon(
                Icons.account_circle_rounded,
                size: 200,
                color: Colors.grey[700],
              ):
              circleProfilePic(),
            const SizedBox(
              height: 15,
            ),
            ListTile(
                title: Text("fullname".tr,
                  style:const TextStyle(color:Colors.black,fontSize: 25,fontWeight:FontWeight.bold),),
            trailing: Text(memberName,
                style:const TextStyle(color:Colors.black,fontSize: 25,fontWeight:FontWeight.bold)),
            ),
            // ListTile(
            //   title: Text(
            //     email,
            //     style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
            //   ),
            //   subtitle:const Text(
            //     "Email",
            //     style: TextStyle(fontSize: 17),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
