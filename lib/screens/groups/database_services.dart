import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");
  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  // saving the userdata
  // Future savingUserData(String fullName, String email) async {
  //   return await userCollection.doc(uid).set({
  //     "name": fullName,
  //     "email": email,
  //     "groups": [],
  //     "profilePic": "",
  //     "uid": uid,
  //     "userchat": [],
  //     "blocklist": [],
  //   });
  // }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  Future gettingUserName() async {
    QuerySnapshot snapshot =
        await userCollection.where("uid", isEqualTo: uid).get();
    String name = snapshot.docs[0]['name'];
    return name;
  }

  // get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  Future<bool> isadmin(String adminName) async {
    //String a = getName(adminName);
    //print("in is admin");
    QuerySnapshot snapshot =
        await userCollection.where("name", isEqualTo: getName(adminName)).get();
    //print("after snapshot");
    if (snapshot.docs.isNotEmpty) {
      //print("in if");
      if (snapshot.docs[0].id == uid) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  // creating a group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
      "blocklist": [],
      //add a field for timestamp called 'recentMessageTime'
      "recentMessageTime": "start",
    });
    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // get group members
  getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // get group members
  getBlocklistMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // search
  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot2 = await groupDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName") &&
        documentSnapshot2['members'].contains("${uid}_$userName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(String groupId, String groupName) async {
    // doc reference
    String userName = await gettingUserName();
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];
    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'],
    });
  }

  String getuserName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getuId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  Future remove(String groupId, int index, String groupName) async {
    // doc reference

    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    Stream members = getGroupMembers(groupId);
    AsyncSnapshot snapshot = members as AsyncSnapshot;
    String ouid = getuId(snapshot.data['members'][index]);
    String userName = getuserName(snapshot.data['members'][index]);
    DocumentReference userDocumentReference = userCollection.doc(ouid);
    // if user has our groups -> then remove then or also in other part re join
    await userDocumentReference.update({
      "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
    });
    await groupDocumentReference.update({
      "members": FieldValue.arrayRemove(["${uid}_$userName"])
    });
  }

  block(String groupId, int index, String groupName) async {
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    Stream members = getGroupMembers(groupId);
    AsyncSnapshot snapshot = members as AsyncSnapshot;
    String ouid = getuId(snapshot.data['members'][index]);
    String userName = getuserName(snapshot.data['members'][index]);
    DocumentReference userDocumentReference = userCollection.doc(ouid);
    // if user has our groups -> then remove then or also in other part re join
    await userDocumentReference.update({
      "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
    });
    await groupDocumentReference.update({
      "members": FieldValue.arrayRemove(["${uid}_$userName"])
    });
    await groupDocumentReference.update({
      "blocklist": FieldValue.arrayUnion(["$uid"])
    });
  }

  Future<bool> isblock(String groupId) async {
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await groupDocumentReference.get();

    List<dynamic> blocklist = await documentSnapshot['blocklist'];
    if (blocklist.contains("$uid")) {
      return true;
    } else {
      return false;
    }
  }
}
