import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class VisitorPage extends StatelessWidget {
  const VisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Espace Visiteur"),
            Text(getFormattedDate(), style: const TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text("Bienvenue à l'ISET Sidi Bouzid")),
    );
  }
}
