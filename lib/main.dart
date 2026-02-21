import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/notification_service.dart';
import 'url_strategy.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> saveUserToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();

  String? token = await messaging.getToken();
  print("FCM TOKEN: $token");

  final user = FirebaseAuth.instance.currentUser;
  if (user == null || token == null) return;

  await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .set({
    "token": token,
    "updatedAt": DateTime.now().toIso8601String(),
  }, SetOptions(merge: true));
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyADcqo-XE3z4NBINFMiPoQ8YRUDmLxr6fU",
        appId: "1:429711477561:android:66f4ce4e3924f4efcaf6e8",
        messagingSenderId: "429711477561",
        projectId: "projectappflutter-adf21",
      ),
    );

    await NotificationService.initialize();
    await saveUserToken();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    // Get FCM Token for Web/Mobile
    String? token = await messaging.getToken(
      vapidKey: "BK73zdfqnDXnKFb3np03ic6WO6G8f-muxzJkoGzQj_-UkvumtrCAwqP6YkYWOtGdC3pZohBC6F7724fI3E3a1MY",
    );

    if (token != null) {
      debugPrint("🔔 FCM TOKEN: $token");
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "token": token
        }, SetOptions(merge: true));
      }
    }

  } catch (e) {
    debugPrint("Initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mototek Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
