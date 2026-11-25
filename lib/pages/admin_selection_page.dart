import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/animated_button.dart';
import 'login_page.dart';
import 'prof_dashboard.dart';
import 'admin_dashboard.dart';

class AdminSelectionPage extends StatelessWidget {
  const AdminSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 80, color: Colors.white),
              const SizedBox(height: 30),
              const Text(
                "Espace Administratif",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              AnimatedButton(
                text: "Prof",
                isOutlined: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(destination: ProfDashboard()),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              AnimatedButton(
                text: "Administration",
                isOutlined: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(destination: AdminDashboard()),
                    ),
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
