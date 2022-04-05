import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:guardian_app_flutter/component/CreateSessionPopup.dart';

import '../component/SessionCardDisplay.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final mySessionsStream = FirebaseFirestore.instance
      .collection("sessions")
      .where("userId", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .where("closed", isEqualTo: false)
      .where("expiryDate", isGreaterThan: DateTime.now())
      .snapshots();

  final belongSessionsStream = FirebaseFirestore.instance
      .collection("sessions")
      .where("users", arrayContains: FirebaseAuth.instance.currentUser?.uid)
      .snapshots();

  final usersCollection = FirebaseFirestore.instance.collection("users");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                return const SessionCreatePopup();
              });
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const Text(
              "Your Sessions",
              style: TextStyle(fontSize: 18),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              child: StreamBuilder(
                  stream: mySessionsStream,
                  builder:
                      (var context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Error occured!");
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator(size: 18, borderWidth: 1);
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Text(
                        "No active sessions!",
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ));
                    }

                    return ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((e) {
                          var data = e.data() as Map<String, dynamic>;

                          return SessionCardDisplay(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed("/session/${e.id}");
                            },
                            key: Key(e.id),
                            sessionId: e.id,
                            user: data,
                          );
                        }).toList(),
                      ),
                    );
                  }),
            ),
            const Text("Guardian of Sessions", style: TextStyle(fontSize: 18)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              child: StreamBuilder(
                  stream: belongSessionsStream,
                  builder:
                      (var context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Error occured!");
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator(size: 18, borderWidth: 1);
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Text(
                        "No sessions that you're guardian of!",
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ));
                    }

                    return ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((e) {
                          var data = e.data() as Map<String, dynamic>;

                          return SessionCardDisplay(
                            onTap: () => {
                              Navigator.of(context)
                                  .pushNamed("/session/${e.id}")
                            },
                            key: Key(e.id),
                            sessionId: e.id,
                            user: data,
                          );
                        }).toList(),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
