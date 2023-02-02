import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/pages/home_page.dart';
import 'package:untitled/service/database_service.dart';
import 'package:untitled/widgets/admin_tile.dart';
import 'package:untitled/widgets/widget.dart';
class GroupInfo extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String adminName;
  final String userName;

  const GroupInfo({Key? key,
  required this.groupName,
  required this.groupId,
  required this.adminName,
    required this.userName
  }) : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  String test="J6JdFwwgwlNRCFJnosda3aW3QmY2_muhsin";
  @override
  void initState() {
    getMembers();
    // TODO: implement initState
    super.initState();
  }
  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }
  String getId(String r){
    return r.substring(0,r.indexOf("_"));
  }
  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title:Text("group info".tr),
        actions: [
          IconButton(onPressed: (){
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("exit".tr),
                    content:Text("want exit".tr),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child:Text("cancel".tr)),
                      TextButton(
                          onPressed: ()async{
                           DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).toggleGroupJoin(widget.groupId, getName(widget.adminName),widget.groupName).whenComplete((){
                             nextScreenReplace(context,const HomePage());
                           });
                          },
                          child:Text("continue".tr))
                    ],
                  );
                });
          }, icon:const Icon(Icons.exit_to_app))
        ],
      ),
      body:Column(
        children: [
          AdminTile(groupName: widget.groupName, adminName: widget.adminName),
          memberList(),
        ],
      )
    );
  }
  memberList(){

    return StreamBuilder(
      stream: members,
      builder:(context, AsyncSnapshot snapshot){
        if(snapshot.hasData){
          if (snapshot.data["members"]!=null){
            if(snapshot.data["members"].length!=0){
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data["members"].length,
                  itemBuilder:(context ,index ){
                    if(getName(widget.adminName)==widget.userName) {
                      return
                        GestureDetector(
                          onLongPress: () {

                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title:Text("exit".tr),
                                    content:Text("want remove".tr),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child:Text("cancel".tr)),
                                      TextButton(
                                          onPressed: ()async{
                                            DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).removeMember(widget.groupId,getName(snapshot.data["members"][index]), getId(snapshot.data["members"][index]),widget.groupName).whenComplete((){
                                              Navigator.of(context).pop();
                                              showSnackbar(context,Colors.green, "Removed Successfully...");
                                            });
                                          },
                                          child:Text("continue".tr))
                                    ],
                                  );
                                });

                          },
                          child: Container(

                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme
                                    .of(context)
                                    .primaryColor,
                                child: Text(
                                  getName(snapshot.data["members"][index])
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                  getName(snapshot.data["members"][index])),
                            ),


                          ),
                        );
                    }
                    else{
                      return Container();
                    }
                  });
            }
            else{
              return const Center(child: Text("No Members"));
            }
          }
          else{
            return const Center(child: Text("No Members"));
          }
        }
        else{
          return //Text(snapshot.toString());
            CircularProgressIndicator(

            color: Theme.of(context).primaryColor,
          );
        }
      },
    );
  }
}
