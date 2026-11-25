import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> courses = [
      {'title': 'Algorithmique', 'prof': 'Dr. Ahmed', 'date': '12 Oct 2023'},
      {'title': 'Base de données', 'prof': 'Mme. Salma', 'date': '10 Oct 2023'},
      {'title': 'Développement Mobile', 'prof': 'Mr. Ali', 'date': '08 Oct 2023'},
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Cours Reçus"),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
              ),
              title: Text(course['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text("Par ${course['prof']}\nEnvoyé le ${course['date']}"),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download_for_offline, color: kPrimaryBlue, size: 30),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Téléchargement de : ${course['title']}...")),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
