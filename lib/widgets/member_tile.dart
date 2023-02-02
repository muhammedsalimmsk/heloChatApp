import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/pages/individual_chatPage.dart';
import 'package:untitled/widgets/widget.dart';
import '../helper/helper_function.dart';
import '../pages/chat_page.dart';
import '../service/database_service.dart';
class MemberTile extends StatefulWidget {
  final String userName;
  final String memberName;
  final String currentUserId;
  final String memberId;
   MemberTile({Key? key,
     required this.userName,
     required this.memberName,
     required this.memberId,
     required this.currentUserId,
  }) : super(key: key);

  @override
  State<MemberTile> createState() => _MemberTileState();
}

class _MemberTileState extends State<MemberTile> {
  User? user;
  bool isJoined=false;
  String userName="";
  String messageId="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName()async{
    await HelperFunctions.getUserNamefromSF().then((value){
      setState(() {
        userName=value!;
      });
    });
    user=FirebaseAuth.instance.currentUser;
  }
  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }


  @override
  Widget build(BuildContext context,) {
    addedOrNot(messageId,widget.memberName,widget.userName);
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child:Text(
              widget.memberName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),),
          title: Text(
            widget.memberName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: InkWell(
            onTap: () async {
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).createUserMessage(widget.userName,widget.memberId,widget.memberName).then((value) {
                setState(() {
                  messageId=value;
                });
              }).whenComplete(()async =>
              await DatabaseService(uid:user!.uid)
                  .toggleAddFriend(widget.memberId ,widget.memberName,widget.userName,messageId,));
              if (isJoined) {
                setState(() {
                  isJoined = !isJoined;
                });
                showSnackbar(context, Colors.green, "Successfully added");
                Future.delayed(const Duration(seconds: 1),(){
                  nextScreen(context, IndividualChatPage(userName: widget.userName, currentUserId: widget.currentUserId,
                      memberName:widget.memberName,
                  messageId:messageId));
                });

              } else {
                setState(() {
                  isJoined = !isJoined;
                  showSnackbar(context, Colors.red, "removed  from friends");
                });
              }
            },
            child: isJoined ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 1),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child:  Text(
                "Added",
                style: TextStyle(color: Colors.white),
              ),
            )
                : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text("Add friend",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        );
  }

  addedOrNot(String messageId,String memberName,String userName)async{
    await DatabaseService(uid:user!.uid).isFriendsAdded(messageId,memberName,userName,).then((value) {
      setState(() {
        isJoined=value;
      });
    });
  }
}


