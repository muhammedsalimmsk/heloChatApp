import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseService{
  final String? uid;
  DatabaseService({this.uid});
  final CollectionReference
  userCollection=FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection=FirebaseFirestore.instance.collection('groups');
  final CollectionReference messageCollection=FirebaseFirestore.instance.collection("userMessages");

  Future updateUserData(String fullName,String email)async{
    return await userCollection.doc(uid).set({
      "fullName":fullName,
      "email": email,
      "groups":[],
      "friends":[],
      "profilePic":'',
      "uid":uid,
      "recentMessage": "",
      "recentMessageSender": "",
    });

  }

  Future gettingUserData(String email)async{
    QuerySnapshot snapshot=await userCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }
 Future editFullName(String userName)async{
 await userCollection.doc(uid).update({
   "fullName":userName
 });
 return userCollection.doc(uid).get();
 }

   getUserGroups()async{
    return userCollection.doc(uid).snapshots();
  }
//upload profile
  Future updateProfile(String profilePic)async{
    DocumentReference userCollectionReference= userCollection.doc(uid);
    userCollectionReference.update({
      "profilePic":profilePic
    });
    return userCollectionReference.get();
  }
  //create message
  Future createUserMessage(String userName,String memberId,String memberName,)async{
    DocumentReference messageDocumentReferece= await messageCollection.add(
        {
          "friends":[],
          "messageId":"",
          "recentMessage": "",
          "recentMessageSender": "",
        });
    await messageDocumentReferece.update({
      "friends":FieldValue.arrayUnion(["${uid}_$userName"]),
      "messageId":messageDocumentReferece.id,
    });
    await messageDocumentReferece.update({
      "friends":FieldValue.arrayUnion(["${memberId}_$memberName"])
    });
    DocumentReference userDocumentReference=userCollection.doc(uid);
    return messageDocumentReferece.id;

  }
//get profile picture
Future getUserProfile()async{
  DocumentReference d=userCollection.doc(uid);
  DocumentSnapshot documentSnapshot= await d.get();
  return documentSnapshot["profilePic"];
}
Future getMemberProfile(String memberId)async{

}
  //crete group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    await groupDocumentReference.update({
          "members": FieldValue.arrayUnion(["${uid}_$userName"]),
           "groupId":groupDocumentReference.id,});
    
    DocumentReference userDocumentReference=userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups": FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  //getting chat
  getMemberChat(String messageId)async{
    return messageCollection.doc(messageId).collection("messages").orderBy("time",descending: true).snapshots();
  }

getChat(String groupId)async{
   return groupCollection.doc(groupId).collection("messages").orderBy("time",descending:true).snapshots();
}
Future getGroupAdmin(String groupId)async{
    DocumentReference d=groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot= await d.get();
    return documentSnapshot["admin"];
}
//get group members
getGroupMembers(groupId)async{
    return groupCollection.doc(groupId).snapshots();
  }
  searchByNameGroup(String groupName)async{
     return groupCollection.where("groupName",isGreaterThanOrEqualTo: groupName).where("groupName",isLessThan: groupName + 'z').get();
  }
searchByNameUser(String groupName)async {
    return await userCollection.where("fullName",isGreaterThanOrEqualTo:groupName).where("fullName",isLessThan: groupName + 'z').get();
}
Future<bool>isUserJoined(String groupName,String groupId,String userName)async{
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot=await userDocumentReference.get();
    List groups=await documentSnapshot["groups"];
    if (groups.contains('${groupId}_$groupName')){
      return true;
    }else{
      return false;
    }
  }

  Future<bool>isFriendsAdded(String messageId,String memberName,String userName,)async{
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot=await userDocumentReference.get();
    List friends=await documentSnapshot["friends"];
    if (friends.contains("${messageId}_$memberName")){
      return true;
    }else{
      return false;
    }
  }

  //toggling add friend

  Future toggleAddFriend(String memberId,memberName,String userName,String messageId)async{
    DocumentReference userDocumentReference=userCollection.doc(uid);
    DocumentReference friendsDocumentReference=userCollection.doc(memberId);
    DocumentReference messageDocumentReference= messageCollection.doc(messageId);
    DocumentSnapshot documentSnapshot=await userDocumentReference.get();
    List friends=await documentSnapshot["friends"];

    if(friends.contains("${messageId}_$memberName")){
      await userDocumentReference.update({"friends":FieldValue.arrayRemove(["${messageId}_$memberName"])});
      await friendsDocumentReference.update({"friends":FieldValue.arrayRemove(["${messageId}_$userName"])});
      await messageDocumentReference.update({"friends":FieldValue.arrayRemove(["${userName}_$memberName"])});
    }
    else{
      await userDocumentReference.update({"friends":FieldValue.arrayUnion(["${messageId}_$memberName"])});
      await friendsDocumentReference.update({"friends":FieldValue.arrayUnion(["${messageId}_$userName"])});
      await messageDocumentReference.update({"friends":FieldValue.arrayUnion(["${userName}_$memberName"])});
    }

  }

  //toggling group join and exit

Future toggleGroupJoin (String groupId,String userName,String groupName)async{
    DocumentReference userDocumentReference =userCollection.doc(uid);
    DocumentReference groupDocumentReference= groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot=await userDocumentReference.get();
    List groups = await documentSnapshot["groups"];

    if(groups.contains("${groupId}_$groupName")){
      await userDocumentReference.update({"groups":FieldValue.arrayRemove(["${groupId}_$groupName"])});
      await groupDocumentReference.update({"members":FieldValue.arrayRemove(["${uid}_$userName"])});
    }
    else{
      await userDocumentReference.update({"groups":FieldValue.arrayUnion(["${groupId}_$groupName"])});
      await groupDocumentReference.update({"members":FieldValue.arrayUnion(["${uid}_$userName"])});
    }

}
//remove members

  Future removeMember(String groupId,String member ,String UId,String groupName)async{
    DocumentReference userDocumentReference =userCollection.doc(UId);
    DocumentReference groupDocumentReference= groupCollection.doc(groupId);
    await userDocumentReference.update({"groups":FieldValue.arrayRemove(["${groupId}_$groupName"])});
    await groupDocumentReference.update({"members":FieldValue.arrayRemove(["${UId}_$member"])});
  }


  // send message by group
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime":chatMessageData['time']
    });
  }
// send message by member
  sendMessageMember(String messageId, Map<String, dynamic> chatMessageData) async {
    messageCollection.doc(messageId).collection("messages").add(chatMessageData);
    messageCollection.doc(messageId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime":chatMessageData['time']
    });

  }
}