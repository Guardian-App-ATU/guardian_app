import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

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
      .snapshots()
      .timeout(const Duration(seconds: 10));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => {},
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Wrap(
                children: [
                  const Text("Guardian Sessions",
                      style: TextStyle(fontSize: 32)),
                  StreamBuilder(
                      stream: mySessionsStream,
                      builder:
                          (var context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Error occured!");
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LoadingIndicator(
                              size: 18, borderWidth: 1);
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                              child: Text(
                            "No active sessions!",
                            style:
                                TextStyle(color: Theme.of(context).hintColor),
                          ));
                        }

                        return ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.docs.map((e) {
                            var data = e.data() as Map<String, dynamic>;

                            return Card(
                              child: ListTile(
                                  title: Text(
                                    e.id.toString(),
                                    style: TextStyle(
                                        color: Theme.of(context).hintColor,
                                        fontSize: 12),
                                  )),
                            );
                          }).toList(),
                        );
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
