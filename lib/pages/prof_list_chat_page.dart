import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'chat_page.dart';

class ProfListChatPage extends StatelessWidget {
  const ProfListChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> professors = [
      {'name': 'Dr. Ahmed', 'specialty': 'Informatique - Algorithmique'},
      {'name': 'Mme. Salma', 'specialty': 'Informatique - Base de données'},
      {'name': 'Mr. Ali', 'specialty': 'Informatique - Développement Mobile'},
      {'name': 'Mme. Ines', 'specialty': 'Réseaux et Télécoms'},
      {'name': 'Mr. Sami', 'specialty': 'Mathématiques'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisir un Professeur"),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: professors.length,
        itemBuilder: (context, index) {
          final prof = professors[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: kPrimaryBlue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                prof['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(prof['specialty']!),
              trailing: const Icon(Icons.chat_bubble_outline, color: kPrimaryBlue),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(title: prof['name']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
