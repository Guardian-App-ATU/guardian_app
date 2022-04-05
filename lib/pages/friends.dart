import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final friendsStream = FirebaseFirestore.instance
      .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add)
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: friendsStream,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Error occured!");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator(size: 18, borderWidth: 1);
            }

            if (!snapshot.hasData) {
              return const Text("No friends found 😔");
            }

            var user = snapshot.data!.data() as dynamic;
            var usersFriends = user!["friends"];

            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemCount: usersFriends?.length ?? 0,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: FirebaseFirestore.instance
                          .doc("users/${usersFriends[index]}")
                          .get(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Error Occured!");
                        }

                        if (!snapshot.hasData) {
                          return const Text("No data returned :(");
                        }

                        var data = snapshot.data!.data() as dynamic;

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: FittedBox(
                            child: Stack(
                              children: [
                                Container(
                                    foregroundDecoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                              Colors.black.withOpacity(.5),
                                              Colors.transparent
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            stops: const [0, 0.55])),
                                    child: Image.network(data!["avatar"])),
                                Positioned(
                                    left: 3,
                                    bottom: 3,
                                    child: Text(
                                      data!["displayName"],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8
                                      ),
                                    ))
                              ],
                            ),
                            fit: BoxFit.fill,
                          ),
                        );
                      });
                });
          },
        ),
      ),
    );
  }
}