import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_data.dart';

class FormsScreen extends StatelessWidget {
  final String role;

  const FormsScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> forms = getFormsByRole(role);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forms"),
      ),
      body: forms.isEmpty
          ? const Center(child: Text("No Forms Available"))
          : ListView.builder(
        itemCount: forms.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(forms[index]["title"]!),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              final Uri uri = Uri.parse(forms[index]["url"]!);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Could not open form")),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
