import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/animated_button.dart';
import 'login_page.dart';
import 'etudiant_dashboard.dart';
import 'visitor_page.dart';
import 'admin_selection_page.dart';
import 'settings_page.dart';

/// Page d'accueil : sélection du type d'utilisateur (Administratif/Prof, Étudiant, Visiteur).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            tooltip: "Paramètres",
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getFormattedDate(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFB3E5FC)],
                ).createShader(bounds),
                child: const Text(
                  "Bienvenue à l'Institut supérieur d'études technologiques",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Image.asset('lib/images/logo.png', height: 120),
              const SizedBox(height: 50),
              AnimatedButton(
                text: "Administratif / Prof",
                isOutlined: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminSelectionPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              AnimatedButton(
                text: "Étudiant",
                isOutlined: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(destination: EtudiantDashboard()),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              AnimatedButton(
                text: "Visiteur",
                isOutlined: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VisitorPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
