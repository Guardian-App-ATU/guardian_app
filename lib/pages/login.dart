import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          child: SignInScreen(
            headerBuilder: (context, _, __) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "Welcome to Guardian!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                    ),
                  ),
                ),
              );
            },
            providerConfigs: const [
              GoogleProviderConfiguration(
                  clientId:
                      '374256029252-k3sd08buibjaktso6brqkkfdr4oa0iot.apps.googleusercontent.com'),
              EmailProviderConfiguration()
            ],
          )),
    );
  }
}
