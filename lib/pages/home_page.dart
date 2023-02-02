import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:untitled/helper/helper_function.dart';
import 'package:untitled/pages/auth/login_page.dart';
import 'package:untitled/pages/profile.dart';
import 'package:untitled/pages/search_page.dart';
import 'package:untitled/service/auth_service.dart';
import 'package:untitled/service/database_service.dart';
import 'package:untitled/widgets/drawer.dart';
import 'package:untitled/widgets/member_tile.dart';
import 'package:untitled/widgets/widget.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../widgets/group_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream? groups;
  String? email;
  String? userName;
  bool _isLoading=true;
  TextEditingController groupName = TextEditingController();
  AuthService authService=AuthService();
  final user=DatabaseService().getUserGroups();
  int currentIndex=0;
  User? currentUser;


  @override
  void initState() {
    super.initState();
    gettingUserData();
  }


  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }
 String getDp(String res){
    return res.substring(res.indexOf("%")+1);
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
     DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups().then((snapshot){
      setState(() {
        groups = snapshot;
      });
    });
  }

  getCurrentUserIdandName()async{
    await HelperFunctions.getUserNamefromSF().then((value){
      setState(() {
        userName=value!;
      });
    });
    currentUser=FirebaseAuth.instance.currentUser;
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
        groupList(),
        friendsList()
    ];

    return WillPopScope(
      onWillPop: ()async{
        final value=await showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                title: Text("alert".tr),
                content: Text("exit app".tr),
                actions: [
                  ElevatedButton(

                      onPressed:(){
                        Navigator.of(context).pop(false);
                      },
                      child: Text("no".tr)
                  ),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.of(context).pop(true);
                      },
                      child:Text("exit".tr)
                  )
                ],
              );
            });
        if(value!=null){
          return Future.value(value);
        }else{
          return Future.value(false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          title: const Text('HeloChat',
              style: TextStyle(
                  fontFamily: 'Hurrycane',
                  fontWeight: FontWeight.bold,
                  fontSize: 27)),
          actions: [
            IconButton(
              onPressed: () {
                nextScreen(context,
                    const SearchPage());
              },
              icon:const Icon(Icons.search),
            )
          ],
        ),
        drawer:const Drawer_Custom(),
        bottomNavigationBar:SalomonBottomBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: [
            SalomonBottomBarItem(
                icon:const Icon(Icons.groups),
                title:Text("groups".tr),
            selectedColor: Theme.of(context).primaryColor),
            SalomonBottomBarItem(
                icon:const Icon(Icons.person),
                title:Text("friends".tr))
          ],

        ),

        body:widgetOptions.elementAt(currentIndex),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            popUpDialogue(context);
          },
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          child:const Icon(Icons.add,color: Colors.white,size: 30,),
        ),
      ),
    );
  }
  popUpDialogue(BuildContext context){
    showDialog(
      barrierDismissible: false,
        context: context, builder: (context){
        return AlertDialog(
          title:  Text("create group".tr,textAlign:TextAlign.left,),
           content : Column(
             mainAxisSize: MainAxisSize.min,
             children: [
            _isLoading==false ? Center(
              child:CircularProgressIndicator(color: Theme.of(context).primaryColor,),
            ):TextField(
              controller: groupName,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide:const BorderSide(
                      color: Colors.red),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:const BorderSide(
                      color: Colors.green),
                    borderRadius: BorderRadius.circular(30),
                  )),
            )
          ],),
            actions: [
            ElevatedButton(
                 onPressed: (){
                   Navigator.of(context).pop();
                 },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: Text("cancel".tr),
      ),
            ElevatedButton(
                 onPressed: ()async{
                   if (groupName.text.isNotEmpty){
                     setState(() {
                       _isLoading=true;
                     });
                     DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).createGroup(userName!,FirebaseAuth.instance.currentUser!.uid, groupName.text).whenComplete(() {
                       _isLoading=false;
                     });
                     Navigator.of(context).pop();
                     showSnackbar(context, Colors.green,"Group created successfully");
                   }else{
                     showSnackbar(context, Colors.red,"Enter valid Name");
                     //const ShakeWidget();
                   }
                 },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                 child: Text("create".tr),
            )
      ],
      );
    });
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              print(snapshot.data.toString());
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                      groupId: getId(snapshot.data['groups'][reverseIndex]),
                      groupName: getName(snapshot.data['groups'][reverseIndex]),
                      userName: snapshot.data['fullName']);
                },
              );
            } else {
              return noGroupWidget();
            }
          }else{
            return noGroupWidget();
          }

        } else {
           return Center(
             child: CircularProgressIndicator(
                 color: Theme.of(context).primaryColor),
           );
          }
        }
        );
  }

  noGroupWidget(){
    return Container(
      padding:const EdgeInsets.symmetric(horizontal: 25),
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: (){
              popUpDialogue(context);
            },
              child: Icon(Icons.add_circle,color:Colors.grey[700],size:75,)),
          const SizedBox(height: 20,),
           Text("not joined".tr,
          style:const TextStyle(fontSize:15 ),textAlign: TextAlign.center,)
        ],
      ),
    );
  }
  friendsList(){
    return StreamBuilder(
      stream: groups,
        builder:(context,AsyncSnapshot snapshot){
        if(snapshot.data!=null){
          if(snapshot.data["friends"] !=null){
            if (snapshot.data['friends'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['friends'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['friends'].length - index - 1;
                  return FriendsTile(
                     context: context,
                      memberName:getName(snapshot.data["friends"][reverseIndex]),
                      userName: userName,
                      currentUserId:FirebaseAuth.instance.currentUser!.uid ,
                      messageId: getId(snapshot.data["friends"][reverseIndex]),
                  );
                },
              );
            } else {
              return noFriendsWidget();
            }
          }else{
            return noFriendsWidget();
          }
        }
        else {
          return Container();
        }
        }
        );

  }
}

