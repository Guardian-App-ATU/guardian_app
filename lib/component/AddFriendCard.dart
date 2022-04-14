import 'package:flutter/material.dart';

class AddFriendCard extends StatelessWidget {
  const AddFriendCard({
    Key? key,
    required this.isYou,
    required this.isFriend,
    required this.user, required this.id,
  }) : super(key: key);

  final bool isYou;
  final bool isFriend;
  final dynamic user;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        visualDensity: VisualDensity.comfortable,
        trailing: !isYou
            ? InkWell(
                onTap: () {},
                child: Icon(!isFriend ? Icons.person_add : Icons.person_remove,
                    size: 32))
            : null,
        title: Text(user["displayName"]),
        tileColor: isYou
            ? Colors.yellow[50]
            : isFriend
                ? Colors.green[50]
                : null,
        subtitle: isYou
            ? const Text("You")
            : isFriend
                ? const Text("Is already your friend")
                : const Text("Isn't your friend"),
      ),
    );
  }
}
