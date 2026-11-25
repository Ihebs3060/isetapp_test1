import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/dash_card.dart';
import 'add_student_page.dart';
import 'admin_publications_page.dart';
import 'manage_stages_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Espace Administration"),
            Text(
              getFormattedDate(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          const DashCard(
            icon: Icons.person_add,
            title: "Ajouter Étudiant",
            destination: AddStudentPage(),
          ),
          const DashCard(
            icon: Icons.event_available,
            title: "Évènements & actus",
            destination: AdminPublicationsPage(),
          ),
          const DashCard(
            icon: Icons.assignment,
            title: "Gérer les Stages",
            destination: ManageStagesPage(),
          ),
          const DashCard(
            icon: Icons.notifications_active,
            title: "Envoyer Avis",
          ),
        ],
      ),
    );
  }
}
