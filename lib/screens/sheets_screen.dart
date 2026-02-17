import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_data.dart';

class SheetsScreen extends StatelessWidget {
  final String role;

  const SheetsScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> sheets = getSheetsByRole(role);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Sheets"),
      ),
      body: sheets.isEmpty
          ? const Center(child: Text("No Sheets Available"))
          : ListView.builder(
        itemCount: sheets.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(sheets[index]["title"]!),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              final Uri uri = Uri.parse(sheets[index]["url"]!);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Could not launch sheet URL")),
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
