import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'forms_screen.dart';
import 'sheets_screen.dart';
import 'calendar_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> saveTask() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();




  print("Task saved with token");
}

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final user = FirebaseAuth.instance.currentUser;

  Future<String?> _getUserRole() async {
    try {
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        return doc.data()?['role'];
      }

      return null;
    } catch (e) {
      debugPrint("Firestore Error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: Text("No role assigned to this user."),
            ),
          );
        }

        String role = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue.shade700,
            title: const Text(
              "Power Drives",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Text(
                      "Logged in as: ${user?.email ?? ""} ($role)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const SizedBox(height: 10),
                        
                        buildCard(context, Icons.description, "Open Forms", Colors.blue, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => FormsScreen(role: role)),
                          );
                        }),

                        const SizedBox(height: 20),

                        buildCard(context, Icons.table_chart, "Open Google Sheets", Colors.green, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SheetsScreen(role: role)),
                          );
                        }),

                        if (role.toUpperCase() == "OWNER") ...[
                          const SizedBox(height: 20),
                          buildCard(context, Icons.calendar_month, "Open Calendar", Colors.orange, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CalendarScreen()),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 15,
                left: 15,
                child: Image.asset(
                  "assets/logo.png",
                  height: 60, // Slightly increased height for better visibility
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Icon(icon, size: 40, color: color),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
