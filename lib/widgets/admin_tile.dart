import 'package:flutter/material.dart';

class AdminTile extends StatelessWidget {
  final String groupName;
  final String adminName;
  const AdminTile({Key? key,
  required this.groupName,
  required this.adminName}) : super(key: key);

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          child: Text(
            getName(adminName).substring(0, 1).toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        title: Text(
          getName(adminName),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Container(
          padding:const EdgeInsets.all(7),
          decoration:const BoxDecoration(
            color: Color(0xFFEAB8C4),
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child:const Text("Group admin",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }
}
