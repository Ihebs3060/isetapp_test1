import 'dart:io';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/animated_button.dart';
import '../widgets/dash_card.dart';
import 'courses_page.dart';
import 'edit_profile_page.dart';
import 'absences_page.dart';
import 'chat_page.dart';
import 'prof_list_chat_page.dart';
import 'stage_page.dart';
import 'student_events_page.dart';

class EtudiantDashboard extends StatefulWidget {
  const EtudiantDashboard({super.key});

  @override
  State<EtudiantDashboard> createState() => _EtudiantDashboardState();
}

class _EtudiantDashboardState extends State<EtudiantDashboard> {
  int _currentIndex = 0;
  
  // Données du profil gérées dans l'état
  String studentName = "Iheb Ben Abdallah";
  String studentEmail = "iheb.abdallah@iset.tn";
  String studentPhone = "+216 22 333 555";
  String studentCity = "Sidi Bouzid";
  File? profileImage;

  void _updateProfile(Map<String, dynamic> data) {
    setState(() {
      studentName = data['name'];
      studentEmail = data['email'];
      studentPhone = data['phone'];
      studentCity = data['city'];
      profileImage = data['image'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const EtudiantHome(),
      StudentProfilePage(
        name: studentName,
        email: studentEmail,
        phone: studentPhone,
        city: studentCity,
        image: profileImage,
        onEdit: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                currentName: studentName,
                currentEmail: studentEmail,
                currentPhone: studentPhone,
                currentCity: studentCity,
              ),
            ),
          ).then((result) {
            if (result != null && result is Map<String, dynamic>) {
              _updateProfile(result);
            }
          });
        },
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: kPrimaryBlue,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 12, 
              backgroundColor: kPrimaryBlue, 
              backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
              child: profileImage == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
            ),
            label: 'Mon Profil',
          ),
        ],
      ),
    );
  }
}

class EtudiantHome extends StatelessWidget {
  const EtudiantHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Espace Étudiant"),
            Text(getFormattedDate(), style: const TextStyle(fontSize: 16)),
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
          const DashCard(icon: Icons.calendar_today, title: "Emploi du temps"),
          const DashCard(icon: Icons.grade, title: "Résultats"),
          const DashCard(icon: Icons.library_books, title: "Cours Reçus", destination: CoursesPage()),
          const DashCard(icon: Icons.person_off, title: "Mes Absences", destination: AbsencesPage()),
          const DashCard(icon: Icons.work_history, title: "Mon Stage", destination: const StagePage()),
          const DashCard(icon: Icons.groups, title: "Chat de Classe", destination: ChatPage(title: "Groupe de Classe")),
          const DashCard(icon: Icons.chat, title: "Chat avec Prof", destination: ProfListChatPage()),
          const DashCard(icon: Icons.event, title: "Évènements", destination: StudentEventsPage()),
        ],
      ),
    );
  }
}

class StudentProfilePage extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String city;
  final File? image;
  final VoidCallback onEdit;

  const StudentProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.image,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
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
                    "Étudiant - RSI",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _profileItem(Icons.badge, "CIN", "11106583"),
                  _profileItem(Icons.email, "Email", email),
                  _profileItem(Icons.phone, "Téléphone", phone),
                  _profileItem(Icons.location_on, "Ville", city),
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
