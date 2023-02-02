import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:untitled/pages/friend_info.dart';
import 'package:untitled/pages/profile.dart';
import 'package:uuid/uuid.dart';
import 'package:grouped_list/grouped_list.dart';
import '../service/database_service.dart';
import '../widgets/message_tile.dart';
import '../widgets/widget.dart';

class IndividualChatPage extends StatefulWidget {
  final String userName;
  final String memberName;
  final String currentUserId;
  final String messageId;
  const IndividualChatPage({Key? key,
    required this.userName,
    required this.messageId,
    required this.currentUserId,
    required this.memberName}) : super(key: key);

  @override
  State<IndividualChatPage> createState() => _IndividualChatPageState();
}
File? image;

class _IndividualChatPageState extends State<IndividualChatPage> {
  TextEditingController messageController=TextEditingController();
  Stream<QuerySnapshot>? chats;
  ScrollController _scrollController=ScrollController();
  getChatAndMember() {
    DatabaseService().getMemberChat(widget.messageId).then((val) {
      setState(() {
        chats = val;
      });
    });
  }
  @override
  void initState() {
    getChatAndMember();
    // TODO: implement initState
    super.initState();
  }


  Future getImage()async{
    ImagePicker picker =ImagePicker();
    picker.pickImage(source: ImageSource.gallery,maxHeight: 400, maxWidth: 250).then((value)
    {
      if (value!=null){
        image=File(value.path);
        uploadImage();
      }
    });
  }


  Future uploadImage()async{
    int status=1;
    String fileName=Uuid().v1();
    var ref=FirebaseStorage.instance.ref().child("images").child("$fileName.jpg");
    var uploadTask=await ref.putFile(image!).catchError((error)async{
      print(error);
      status=0;
    });
    if(status==1){
      String imageUrl=await uploadTask.ref.getDownloadURL();
      Map<String , dynamic>chatMessageMap={
        "message":imageUrl,
        "type":"img",
        "sender":widget.userName,
        "time":DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService().sendMessageMember(widget.messageId
        ,chatMessageMap,);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.memberName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: (){
              nextScreen(context,FriendInfo(memberName: widget.memberName));
            },
            icon:const Icon(Icons.info_outline),)
        ],
      ),
      body:Container (
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: chatMessage()),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child:Container(
                width: MediaQuery.of(context).size.width,
                height: 65,
                color: Colors.grey,
                padding:const EdgeInsets.symmetric(horizontal: 20,vertical: 13),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: messageController,
                        style:const TextStyle(color:Colors.white),
                        decoration:const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Send a message...",
                            hintStyle: TextStyle(
                                color: Colors.white
                            )
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        getImage();
                      },
                      child:const SizedBox(
                        height: 50,
                        width: 50,
                        child:const Icon(Icons.image,color: Colors.white,size:30,),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        _scrollController.animateTo(_scrollController.position.minScrollExtent, duration:const Duration(milliseconds: 300), curve: Curves.easeOut);
                        sendMessage();
                        },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration:BoxDecoration(
                            color:Theme.of(context).primaryColor,
                            borderRadius:const BorderRadius.all(Radius.circular(30))
                        ),
                        child:const Icon(Icons.send,color: Colors.white,),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  chatMessage(){
    return StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot){
          return snapshot.hasData?
          ListView.builder(
            reverse: true,
            controller: _scrollController,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context,index){
              return MessageTile(
                  message: snapshot.data.docs[index]["message"],
                  type: snapshot.data.docs[index]["type"],
                  sender: snapshot.data.docs[index]["sender"],
                  time: snapshot.data.docs[index]["time"],
                  sendByMe:widget.userName==snapshot.data.docs[index]["sender"],);
            }
              )
              :Container();
        });

  }
  sendMessage(){
    if(messageController.text.isNotEmpty){
      Map<String , dynamic>chatMessageMap={
        "message":messageController.text,
        "type":"text",
        "sender":widget.userName,
        "time":DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService().sendMessageMember(widget.messageId
        ,chatMessageMap,);
      setState(() {
        messageController.clear();
      });
    }

  }
}
