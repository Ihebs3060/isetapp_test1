import 'dart:io';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/dash_card.dart';
import '../widgets/animated_button.dart';
import 'attendance_page.dart';
import 'grading_page.dart';
import 'upload_course_page.dart';
import 'edit_profile_page.dart';

class ProfDashboard extends StatefulWidget {
  const ProfDashboard({super.key});

  @override
  State<ProfDashboard> createState() => _ProfDashboardState();
}

class _ProfDashboardState extends State<ProfDashboard> {
  int _currentIndex = 0;

  // Données du profil enseignant
  String profName = "Prof. Nom Prénom";
  String profEmail = "professeur@iset.tn";
  String profPhone = "+216 76 000 000";
  String profSpecialty = "Développement Mobile";
  File? profileImage;

  void _updateProfile(Map<String, dynamic> data) {
    setState(() {
      profName = data['name'];
      profEmail = data['email'];
      profPhone = data['phone'];
      // Note: On pourrait ajouter la spécialité dans EditProfilePage si besoin
      profileImage = data['image'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const ProfHome(),
      ProfProfilePage(
        name: profName,
        email: profEmail,
        phone: profPhone,
        specialty: profSpecialty,
        image: profileImage,
        onEdit: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                currentName: profName,
                currentEmail: profEmail,
                currentPhone: profPhone,
                currentCity: profSpecialty, // Utilise ville pour spécialité ici
              ),
            ),
          );

          if (result != null && result is Map<String, dynamic>) {
            _updateProfile(result);
          }
        },
      ),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: kPrimaryBlue,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tableau de bord'),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 12, 
              backgroundColor: kPrimaryBlue, 
              backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
              child: profileImage == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
            ),
            label: 'Mon Compte',
          ),
        ],
      ),
    );
  }
}

class ProfHome extends StatelessWidget {
  const ProfHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Espace Enseignant"),
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
          const DashCard(icon: Icons.calendar_month, title: "Emploi du temps"),
          const DashCard(icon: Icons.group, title: "Mes Étudiants", destination: AttendancePage()),
          const DashCard(icon: Icons.assignment, title: "Saisie des Notes", destination: GradingPage()),
          const DashCard(icon: Icons.upload_file, title: "Envoyer Cours", destination: UploadCoursePage()),
          const DashCard(icon: Icons.notifications, title: "Avis"),
        ],
      ),
    );
  }
}

class ProfProfilePage extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final File? image;
  final VoidCallback onEdit;

  const ProfProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.image,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Compte"),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: kPrimaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: image != null ? FileImage(image!) : null,
                    child: image == null ? const Icon(Icons.person, size: 80, color: kPrimaryBlue) : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Département Informatique",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _profileItem(Icons.email, "Email", email),
                  _profileItem(Icons.phone, "Téléphone", phone),
                  _profileItem(Icons.work, "Spécialité", specialty),
                  const SizedBox(height: 30),
                  AnimatedButton(
                    text: "MODIFIER LE PROFIL",
                    onPressed: onEdit,
                  ),
                  const SizedBox(height: 15),
                  AnimatedButton(
                    text: "DÉCONNEXION",
                    color: Colors.red,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: kPrimaryBlue),
        title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
