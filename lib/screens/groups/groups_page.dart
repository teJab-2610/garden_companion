import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:garden_companion_2/screens/groups/widgets/group_tile.dart';
import 'package:garden_companion_2/screens/groups/widgets/widgets.dart';
import 'database_services.dart';
import 'search_page.dart';

//Group page is a page where all the groups joined by user are displayed
class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  String userName = ""; //name of user
  String email = ""; //email of user
  Stream? groups; //stream of groups where user is present
  Stream? users; //stream of users
  bool _isLoading = false; //for loading indicator
  String groupName = ""; //name of group

  @override
  void initState() {
    super.initState(); //initializing state
    gettingUserData(); //getting user data
  }

  // string manipulation

  //users are stored in groups collection in field members in the form of uid_name
  //groups are stored in users in field groups in the form of groupId_groupName

  //getId and getName are used to get id and name from the string, where _ is seperator for identification of id and name
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  //getting user data
  gettingUserData() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .gettingUserData(FirebaseAuth.instance.currentUser!.email!)
        .then((snapshot) {
      setState(() {
        userName = snapshot.docs[0]['name'];
        email = snapshot.docs[0]['email'];
      });
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const SearchPage())); //search page is linked to this
              },
              icon: const Icon(
                Icons.search, //search icon
              ))
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text(
          "Groups",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 27,
              fontFamily: 'Sf'),
        ),
      ),
      body: groupList(), //groups are displayed here as list
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context); //pop up dialog is displayed to create a group
        },
        elevation: 0,
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add, //add icon
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    //popup dialog to create a group, a text field is present to enter group name
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: const Text(
                "Create a group",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Colors.green), //loading indicator/symbol
                        )
                      : TextField(
                          onChanged: (val) {
                            setState(() {
                              groupName =
                                  val; //group name is stored in groupName
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                  borderRadius: BorderRadius.circular(20)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(20)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                  borderRadius: BorderRadius.circular(20))),
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (groupName != "") {
                      setState(() {
                        _isLoading = true;
                      });
                      DatabaseService(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .createGroup(userName,
                              FirebaseAuth.instance.currentUser!.uid, groupName)
                          .whenComplete(() {
                        //group is created using createGroup function in database_services.dart
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                      showSnackbar(
                          context, Colors.green, "Group created successfully.");
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("CREATE"),
                )
              ],
            );
          }));
        });
  }

  groupList() {
    //builds list of groups in which user is present and displays them
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        //snapshot of users collection,contains all the data regarding user
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                      //each group is displayed as a tile
                      groupId: getId(snapshot.data['groups'][reverseIndex]),
                      groupName: getName(snapshot.data['groups'][reverseIndex]),
                      userName:
                          snapshot.data['name']); //gets user name from snapshot
                },
              );
            } else {
              return noGroupWidget(); //if no groups are present then noGroupWidget is displayed
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return const Center(
            child: Text("Create Group"),
          );
        }
      },
    );
  }

  noGroupWidget() {
    //noGroupWidget is displayed when no groups are present
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle, //add icon
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
