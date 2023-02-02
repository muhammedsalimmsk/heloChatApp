import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:untitled/pages/group_info.dart';
import 'package:untitled/service/database_service.dart';
import 'package:untitled/widgets/message_tile.dart';
import 'package:untitled/widgets/widget.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const ChatPage({Key? key,
  required this.groupId,
  required this.groupName,
  required this.userName}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

File? image;
class _ChatPageState extends State<ChatPage> {
  String admin="";
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController=TextEditingController();
  ScrollController _scrollController=ScrollController();


  @override
  void initState() {
    getChatandAdmin();
    // TODO: implement initState
    super.initState();
  }
  getChatandAdmin(){
    DatabaseService().getChat(widget.groupId).then((val){
      setState(() {
        chats=val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        admin=value;
      });
    });

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
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
          onPressed: (){
            nextScreen(context, GroupInfo(groupId: widget.groupId,groupName: widget.groupName,adminName: admin,userName: widget.userName,));
          }, 
            icon:const Icon(Icons.info_outline),)
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: chatMessage()),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child:Container(
              width: MediaQuery.of(context).size.width,
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
                          borderRadius:const BorderRadius.all(Radius.circular(20))
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
                      type: snapshot.data.docs[index]["type"],
                      message: snapshot.data.docs[index]["message"],
                      sender: snapshot.data.docs[index]["sender"],
                      time: snapshot.data.docs[index]["time"],
                      sendByMe:widget.userName==snapshot.data.docs[index]["sender"],);
                  })
              :const Center(
                   child:Text("i am sorry"),
          );

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
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }

  }
}


