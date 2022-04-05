import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guardian_app_flutter/pages/friends.dart';
import 'package:guardian_app_flutter/pages/login.dart';
import 'package:guardian_app_flutter/pages/main_page.dart';
import 'package:guardian_app_flutter/pages/profile.dart';
import 'package:guardian_app_flutter/pages/session.dart';
import 'package:guardian_app_flutter/services/AuthenticationService.dart';
import 'package:guardian_app_flutter/services/LocationService.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (defaultTargetPlatform == TargetPlatform.android){
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

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
        Provider<LocationService>(
          create: (_) => LocationService(autoAskForPermission: true),
        ),
        StreamProvider(create: (context) => context.read<LocationService>().location.onLocationChanged, initialData: null),
        StreamProvider(
            initialData: FirebaseAuth.instance.currentUser,
            create: (context) =>
                context.read<AuthenticationService>().authStateChanged)
      ],
      child: GetMaterialApp(
        title: "Guardian",
        theme: ThemeData(primarySwatch: Colors.purple),
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class NamedRoute {
  final String route;
  final String topName;

  const NamedRoute(this.route, this.topName);
}

class GuardianAppPage extends StatefulWidget {
  const GuardianAppPage({Key? key}) : super(key: key);

  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<GuardianAppPage> createState() => _GuardianAppPageState();
}

class _GuardianAppPageState extends State<GuardianAppPage> {
  int _selectedIndex = 1;

  final _navigatorKey = GuardianAppPage._navigatorKey;

  _changeIndex(int index, BuildContext context) {
    if(index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    _navigatorKey.currentState!.pushNamed(Widgets[_selectedIndex].route);
  }

  List<NamedRoute> Widgets = const [
    NamedRoute("/friends", "Friends"),
    NamedRoute("/", "Sessions"),
    NamedRoute("/profile", "You"),
    NamedRoute("/archive", "Archived"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Widgets[_selectedIndex].topName),
        actions: [
          PopupMenuButton<int>(onSelected: (val) {
            _navigatorKey.currentState!
                .pushNamed(Widgets[_selectedIndex].route);
          }, itemBuilder: (BuildContext context) {
            return const [
              PopupMenuItem<int>(
                child: Text("Friends"),
                value: 2,
              )
            ];
          })
        ],
      ),
      body: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;

          switch (settings.name) {
            case "/profile":
              builder = (BuildContext context) => const ProfilePage();
              break;
            case "/friends":
              builder = (BuildContext context) => const FriendsPage();
              break;
            case "/":
            default:
              builder = (BuildContext context) => const MainPage();
          }

          if(settings.name!.startsWith("/session/")){
            final String extracted = settings.name!.substring("/session/".length);
            builder = (BuildContext context) => SessionPage(sessionId: extracted);
          }

          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _changeIndex(index, context);
        },
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: "Friends"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Main Page"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: "You"),
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
