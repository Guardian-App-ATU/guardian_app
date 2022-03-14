import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:intl/intl.dart';

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
          var callable =
              FirebaseFunctions.instance.httpsCallable("createSession");
          callable
              .call(<String, dynamic>{"expire": ""}).then((value) => print);
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

                          var now = DateTime.now();
                          var expiry = data["expiryDate"] as Timestamp;

                          var difference =
                              now.difference(expiry.toDate()).abs();

                          return Dismissible(
                            key: Key(e.id),
                            confirmDismiss: (dir) async {
                              return await showDialog(
                                  context: context,
                                  builder: (buildcontext) {
                                    return AlertDialog(
                                      title:
                                          const Text("Wait! Are you sure?"),
                                      content: const Text(
                                          "This will remove (forever!) this guardian session!"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(buildcontext)
                                                    .pop(false),
                                            child: const Text("Cancel"),
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.red))),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(buildcontext)
                                                    .pop(true),
                                            child: const Text(
                                                "I'm okay with that!"))
                                      ],
                                    );
                                  });
                            },
                            onDismissed: (dir) {
                              // --TODO: Do something on dismissal
                            },
                            child: Card(
                              elevation: 3,
                              child: ListTile(
                                  leading: FutureBuilder<DocumentSnapshot>(
                                    future: usersCollection
                                        .doc(data['userId'])
                                        .get(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            snap) {
                                      if (snap.hasError || !snap.hasData) {
                                        return const CircleAvatar(
                                          child: Icon(Icons.error_outline),
                                        );
                                      }

                                      var data = snap.data!.data()
                                          as Map<String, dynamic>;
                                      return CircleAvatar(
                                        child:
                                            const Icon(Icons.error_outline),
                                        foregroundImage:
                                            Image.network(data["avatar"])
                                                .image,
                                      );
                                    },
                                  ),
                                  subtitle: Text(e.id.toString()),
                                  trailing: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 50),
                                      child: Text(
                                        "last update ${0}m ago",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                Theme.of(context).hintColor),
                                      )),
                                  title: Text(
                                    "${DateFormat("MMMM dd").format((data["createdAt"] as Timestamp).toDate())} Guardian Session",
                                  )),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
            ),
            const Text("Guardian of Sessions",
                style: TextStyle(fontSize: 18)),
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
