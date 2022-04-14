import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/AddFriendCard.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({Key? key}) : super(key: key);

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  final textController = TextEditingController();

  Stream<QuerySnapshot> searchStream = Stream.empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: textController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Search by display name"),
          ),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    searchStream = FirebaseFirestore.instance
                        .collection("users")
                        .snapshots();
                  });
                },
                child: const Text("Search")),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          const Text("Search Results"),
          FutureBuilder(
            future: FirebaseFirestore.instance
                .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
                .get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(
                  child: Text("Failed to get user profile"),
                );
              }

              dynamic friendsData = snapshot.data!.data();
              List<String> friendsArray = [...friendsData["friends"]];

              return StreamBuilder<QuerySnapshot>(
                  stream: searchStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text("An error occurred"));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: Text("No data"));
                    }

                    List<dynamic> users = snapshot.data!.docs;

                    users = users
                        .where((element) => element["displayName"]
                            .startsWith(textController.text))
                        .toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        bool isFriend =
                            friendsArray.contains(users[index].reference.id);

                        bool isYou = users[index].reference.id ==
                            FirebaseAuth.instance.currentUser!.uid;

                        var user = users[index];

                        return AddFriendCard(isYou: isYou, isFriend: isFriend, user: user);
                      },
                    );
                  });
            },
          )
        ],
      ),
    );
  }
}

