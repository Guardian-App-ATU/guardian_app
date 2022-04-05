import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionCardDisplay extends StatelessWidget {
  const SessionCardDisplay(
      {required Key key,
      required this.user,
      required this.sessionId,
      required this.onTap})
      : super(key: key);

  final Map<String, dynamic> user;
  final String sessionId;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final usersCollection = FirebaseFirestore.instance.collection("users");

    return Dismissible(
      key: key!,
      confirmDismiss: (dir) async {
        return await showDialog(
            context: context,
            builder: (buildcontext) {
              return AlertDialog(
                title: const Text("Wait! Are you sure?"),
                content: const Text(
                    "This will close (forever!) this guardian session!"),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.of(buildcontext).pop(false),
                      child: const Text("Cancel"),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red))),
                  TextButton(
                      onPressed: () => Navigator.of(buildcontext).pop(true),
                      child: const Text("I'm okay with that!"))
                ],
              );
            });
      },
      onDismissed: (dir) async {
        var httpsCallable =
            FirebaseFunctions.instance.httpsCallable("closeSession");

        await httpsCallable.call(<String, dynamic>{"session": sessionId});
      },
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 3,
          child: ListTile(
              leading: FutureBuilder<DocumentSnapshot>(
                future: usersCollection.doc(user['userId']).get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snap) {
                  if (snap.hasError || !snap.hasData) {
                    return const CircleAvatar(
                      child: Icon(Icons.error_outline),
                    );
                  }

                  var data = snap.data!.data() as Map<String, dynamic>;
                  return CircleAvatar(
                    child: const Icon(Icons.error_outline),
                    foregroundImage: Image.network(data["avatar"]).image,
                  );
                },
              ),
              subtitle: Text(
                "Expires ${DateFormat("MMMM dd 'at' HH:MMa").format((user["expiryDate"] as Timestamp).toDate())}",
              ),
              trailing: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 50),
                  child: Text(
                    "last update ${0}m ago",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, color: Theme.of(context).hintColor),
                  )),
              title: Text(
                "${DateFormat("MMMM dd").format((user["createdAt"] as Timestamp).toDate())} Guardian Session",
              )),
        ),
      ),
    );
  }
}