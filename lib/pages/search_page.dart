import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/helper/helper_function.dart';
import 'package:untitled/service/database_service.dart';
import 'package:untitled/widgets/member_tile.dart';
import '../widgets/widget.dart';
import 'chat_page.dart';
class SearchPage extends StatefulWidget {
   const SearchPage({Key? key,}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController=TextEditingController();
  bool isLoading=false;
  QuerySnapshot? searchSnapshot;
   QuerySnapshot? userSnapshot;
   QuerySnapshot? messageSnapshot;
  bool hasUserSearched=false;
  String userName="";
  User? user;
  bool isJoined=false;


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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title:Text("search".tr,style:const TextStyle(fontSize: 27,fontWeight: FontWeight.bold,color: Colors.white,),)
      ),
      body: Column(
        children: [
          Container(
            padding:const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style:const TextStyle(color:Colors.white,),
                    decoration:InputDecoration(
                      border: InputBorder.none,
                      hintText: "searching".tr,
                      hintStyle:const TextStyle(color: Colors.white,fontSize: 16),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    initiateSearchMethod();
                    },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration:BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.white.withOpacity(0.1)
                    ),
                    child:const Icon(Icons.search,color: Colors.white,),
                  ),
                )
              ],
            ),
          ),
          isLoading?Center(
            child: CircularProgressIndicator(color: Theme.of(context).appBarTheme.backgroundColor,),
          ):groupList()

          // membersList(),
        ],
      ),
    );
  }

  initiateSearchMethod()async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      await DatabaseService().searchByNameUser(searchController.text).then((
          snapshot) {
        setState(() {
          userSnapshot = snapshot;
          isLoading=false;
          hasUserSearched = true;
        });
      });
      await DatabaseService().searchByNameGroup(searchController.text).then((snapshot){
        setState(() {
          searchSnapshot=snapshot;
          isLoading=false;
          hasUserSearched=true;
        });
      });
    }
  }




  groupList() {
    return hasUserSearched
        ? Expanded(
          child: Column(
            children: [
              ListView.builder(
      shrinkWrap: true,
      itemCount: userSnapshot!.docs.length,
      itemBuilder: (context, index) {
              return MemberTile(
                userName: userName,
                memberName: userSnapshot!.docs[index]["fullName"],
                memberId: userSnapshot!.docs[index]["uid"],
                currentUserId: FirebaseAuth.instance.currentUser!.uid,
                );
      },

    ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: searchSnapshot!.docs.length,
                itemBuilder: (context, index) {
                  return groupTile(userName,
                      searchSnapshot!.docs[index]["groupId"],
                      searchSnapshot!.docs[index]["groupName"],
                      searchSnapshot!.docs[index]["admin"]);
                },
              )

            ],
          ),
        )
        : Container();
  }
  joinedOrNot(String userName,String groupId,String groupName,String admin)async{
    await DatabaseService(uid: user!.uid).isUserJoined(groupName, groupId, userName).then((value) {
      setState(() {
        isJoined=value;
      });
    });
  }
  Widget  groupTile(
      String userName, String groupId, String groupName, String admin) {
    // function to check whether user already exists in group
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title:
      Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toggleGroupJoin(groupId, userName, groupName);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, Colors.green, "Successfully joined the group");
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
              showSnackbar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: isJoined
            ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child:Text(
                    "joined".tr,
            style:const TextStyle(color: Colors.white),
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
                child:Text("join now".tr,
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }




}
