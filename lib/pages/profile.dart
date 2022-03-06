import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:get/get.dart';
import 'package:guardian_app_flutter/services/AuthenticationService.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const iconMap = {"google.com": Icons.verified_user};

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    final theme = Theme.of(context);

    final providers = user?.providerData ?? [];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        runSpacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const UserAvatar(),
                  const SizedBox(height: 8),
                  Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 2,
                    children: [
                      Text(user?.displayName ?? "User",
                          style:
                          TextStyle(fontSize: 18, color: theme.primaryColor)),
                      Text(user?.email ?? "",
                          style: TextStyle(color: theme.hintColor)),
                      Text(
                          "Account created ${new DateFormat("MMMM dd, yyyy").format(user!.metadata.creationTime!)}",
                          style: TextStyle(color: theme.hintColor))
                    ],
                  )
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("Linked Socials", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: providers
                        .map((e) => Tooltip(
                            message: e.providerId,
                            child: Icon(providerIcon(context, e.providerId))))
                        .toList(),
                  ))
            ],
          ),
          Column(
            children: [
              SizedBox(
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<AuthenticationService>().logOut();
                    Get.rawSnackbar(
                        message: "Logged out", snackStyle: SnackStyle.GROUNDED);
                  },
                  child: const Center(child: Text("Log out")),
                ),
              ),
              SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () async {
                    await context.read<AuthenticationService>().deleteUser();
                    Get.rawSnackbar(
                        message:
                            "Your account has been deleted, sad to see you go!",
                        snackStyle: SnackStyle.GROUNDED);
                  },
                  child: const Center(child: Text("Delete Account")),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
