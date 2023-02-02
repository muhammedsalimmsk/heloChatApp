import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("privacy".tr),
        centerTitle: true,
      ),
      body:Text("privacy rule".tr,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
    );
  }
}
