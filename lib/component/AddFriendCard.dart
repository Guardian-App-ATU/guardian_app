import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFriendCard extends StatefulWidget {
  const AddFriendCard({
    Key? key,
    required this.isYou,
    required this.isFriend,
    required this.user,
    required this.id,
  }) : super(key: key);

  final bool isYou;
  final bool isFriend;
  final dynamic user;
  final String id;

  @override
  State<AddFriendCard> createState() => _AddFriendCardState();
}

class _AddFriendCardState extends State<AddFriendCard> {
  late bool isFriend;

  @override
  void initState() {
    isFriend = widget.isFriend;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        visualDensity: VisualDensity.comfortable,
        trailing: !widget.isYou
            ? InkWell(
                onTap: () async {
                  var dialogCtx;
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) {
                        dialogCtx = dialogContext;

                        return const Center(child: CircularProgressIndicator());
                      });

                  await FirebaseFirestore.instance
                      .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
                      .update({
                    "friends": isFriend
                        ? FieldValue.arrayRemove([widget.id])
                        : FieldValue.arrayUnion([widget.id])
                  });

                  await Future.delayed(const Duration(milliseconds: 125));

                  setState(() {
                    isFriend = !isFriend;
                  });

                  Navigator.of(dialogCtx).pop();
                },
                child: Icon(!isFriend ? Icons.person_add : Icons.person_remove,
                    size: 32))
            : null,
        title: Text(widget.user["displayName"]),
        tileColor: widget.isYou
            ? Colors.yellow[50]
            : isFriend
                ? Colors.green[50]
                : null,
        subtitle: widget.isYou
            ? const Text("You")
            : isFriend
                ? const Text("Is already your friend")
                : const Text("Isn't your friend"),
      ),
    );
  }
}
