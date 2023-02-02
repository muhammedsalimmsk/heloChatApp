import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/pages/profile.dart';
import 'package:untitled/pages/individual_chatPage.dart';

import '../service/database_service.dart';
import 'message_tile.dart';

const textInputDecoration=InputDecoration(
  labelStyle: TextStyle(color: Colors.black,fontWeight:FontWeight.w400),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFBA133B),width: 2)
  ),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFBA133B),width: 2)
    ),
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFBA133B),width: 2)
    )
);

void nextScreen(context,page){

  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}
void nextScreenPop(context,page){
  Navigator.pop(context,MaterialPageRoute(builder: (context)=>page));
}
void nextScreenpoppush(context,page){
  Navigator.popAndPushNamed(context, page);
}

void nextScreenReplace(context,page){
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void showSnackbar(context,color,message){
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content:
  Text(message,style: const TextStyle(fontSize: 14),),
  backgroundColor: color,
  duration: Duration(seconds:2),
  action: SnackBarAction(
    label: 'OK',
    onPressed: (){},
    textColor: Colors.white,
  ),),);
}

class DrawerList extends StatelessWidget {
  const DrawerList({Key? key,required this.text,required this.icon,required this.onTap}) : super(key: key);
final String text;
final IconData icon;
final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
    contentPadding:const EdgeInsets.symmetric(horizontal: 20,vertical: 2),
    leading:Icon(icon),
    title:Text(text,style:const TextStyle(fontSize: 17,fontWeight: FontWeight.bold,)),
    onTap: onTap,);
  }
}
@immutable
class ShakeWidget extends StatelessWidget {
  final Duration duration;
  final double deltaX;
  final Widget? child;
  final Curve curve;

  const ShakeWidget({
     Key? key,
    this.duration = const Duration(milliseconds: 500),
    this.deltaX = 20,
    this.curve = Curves.bounceOut,
    this.child,
  }) : super(key: key);

  /// convert 0-1 to 0-1-0
  double shake(double animation) =>
      2 * (0.5 - (0.5 - curve.transform(animation)).abs());

  String getName(String res) {
    return res.substring(0, res.indexOf(""));
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, animation, child) => Transform.translate(
        offset: Offset(deltaX * shake(animation), 0),
        child: child,
      ),
      child: child,
    );
  }
}

Widget FriendsTile({required userName,required currentUserId,required messageId,memberName,required BuildContext context}){
  return GestureDetector(
    onTap:(){
      nextScreen(context, IndividualChatPage(
        messageId: messageId,
        userName: userName,
        currentUserId: currentUserId,
        memberName: memberName,
        ));
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            memberName.substring(0, 1).toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        title: Text(
          memberName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}

noFriendsWidget(){
  return Container(
    padding:const EdgeInsets.symmetric(horizontal: 25),
    child:Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:const [
         SizedBox(height: 20,),
         Text("You have't any friends, tap on the search icon to search friends and add them.",
          style: TextStyle(fontSize:18,color: Colors.grey),textAlign: TextAlign.center,),
      ],
    ),
  );
}

circleProfilePic(){
  return CircleAvatar(
    radius: 75,
    backgroundColor: Color(0xFFBA133B),
    child: CircleAvatar(
      radius: 70,
      backgroundImage:NetworkImage(profilePic,),
    ),
  );
}

Widget createGroupHeader(time) {
  return SizedBox(
    height: 40,
    child: Align(
      child: Container(
        width: 120,
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(DateFormat('ymd')
      .format(DateTime.fromMillisecondsSinceEpoch(time))),
        ),
      ),
    ),
  );
}