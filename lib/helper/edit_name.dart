import 'package:flutter/material.dart';
import 'package:untitled/service/database_service.dart';
class EditFullName extends StatefulWidget {
  final String userName;
  final String uid;


  const EditFullName({Key? key,
  required this.userName,
  required this.uid}) : super(key: key);




  @override
  State<EditFullName> createState() => _EditFullNameState();
}



class _EditFullNameState extends State<EditFullName> {
  bool isLoading=false;
  final  TextEditingController editingController=TextEditingController();
  Map? userdate;
  String userName="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userName=widget.userName;
    editingController.text=userName;
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    editingController.dispose();

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title:const Text("Fullname"),
        actions: [
          IconButton(
            onPressed: ()async{
              await DatabaseService(uid:widget.uid).editFullName(editingController.text).then((value) {
                setState(() {
                  userdate=value;
                  userName=userdate!["fullName"];
                });
                isLoading=false;
              }).whenComplete((){
                Navigator.pop(context);
              });
              },
            icon:const Icon(Icons.done,color: Colors.white,),),
        ],
      ),
      body:Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration:const BoxDecoration(
          color:Colors.white
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height:10,),
            Text("Set fullname",
              style:TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 17,fontWeight: FontWeight.bold)
              ,),
            TextFormField(
              controller: editingController,
              enabled: true,
              style: const TextStyle(fontSize:20,fontWeight:FontWeight.bold),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color:Theme.of(context).primaryColor),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
