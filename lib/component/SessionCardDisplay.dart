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
    var userRef = usersCollection.doc(user['userId']).get();

    var lastUpdated = user["lastUpdate"];
    if (lastUpdated == null) {
      lastUpdated = "never updated";
    } else {
      var date = lastUpdated as Timestamp;
      var difference =
          Timestamp.now().toDate().difference(date.toDate()).inMinutes;

      lastUpdated = "last updated ${difference}m ago";
    }

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
                      onPressed: () async {
                        var httpsCallable = FirebaseFunctions.instance
                            .httpsCallable("closeSession");

                        showDialog(context: buildcontext, barrierDismissible: false, builder: (cntx) {
                           return const Center(
                             child: CircularProgressIndicator(),
                           );
                        });

                        await httpsCallable
                            .call(<String, dynamic>{"session": sessionId});

                        // Pop twice, once to remove the loading indicator, second time to remove the modal
                        Navigator.of(buildcontext).pop(true);
                        Navigator.of(buildcontext).pop(true);
                      },
                      child: const Text("I'm okay with that!"))
                ],
              );
            });
      },
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 3,
          child: ListTile(
              leading: FutureBuilder<DocumentSnapshot>(
                future: userRef,
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snap) {
                  if (snap.hasError || !snap.hasData) {
                    return const CircleAvatar(
                      child: Icon(Icons.error_outline),
                    );
                  }

                  var data = snap.data!.data() as Map<String, dynamic>;
                  var avatar = data["avatar"];
                  return CircleAvatar(
                    child: const Icon(Icons.error_outline),
                    foregroundImage:
                        avatar != null ? Image.network(avatar).image : null,
                  );
                },
              ),
              subtitle: Text(
                "Expires ${DateFormat("MMMM dd 'at' HH:MMa").format((user["expiryDate"] as Timestamp).toDate())}",
              ),
              trailing: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 50),
                  child: Text(
                    lastUpdated,
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
