import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardian_app_flutter/pages/login.dart';
import 'package:guardian_app_flutter/pages/profile.dart';
import 'package:guardian_app_flutter/services/AuthenticationService.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
            initialData: FirebaseAuth.instance.currentUser,
            create: (context) =>
                context.read<AuthenticationService>().authStateChanged)
      ],
      child: GetMaterialApp(
        title: "Guardian",
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class GuardianAppPage extends StatefulWidget {
  const GuardianAppPage({Key? key}) : super(key: key);

  @override
  State<GuardianAppPage> createState() => _GuardianAppPageState();
}

class _GuardianAppPageState extends State<GuardianAppPage> {
  int _selectedIndex = 0;

  _changeIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> Widgets = const [
    ProfilePage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Widgets.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _changeIndex,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Main Page"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: "You")
        ],
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser == null) {
      return const LoginPage();
    }

    return const GuardianAppPage();
  }
}
