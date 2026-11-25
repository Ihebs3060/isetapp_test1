import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class StageStatusPage extends StatelessWidget {
  final bool isAccepted; // Simulation: changez à true pour voir l'acceptation

  const StageStatusPage({super.key, this.isAccepted = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statut de mon Stage"),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isAccepted)
                _buildAcceptedView()
              else
                _buildRefusedView(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptedView() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 100),
        const SizedBox(height: 20),
        const Text(
          "Félicitations !",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 10),
        const Text(
          "Votre demande de stage a été acceptée.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 30),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info, color: kPrimaryBlue),
            title: Text("Veuillez passer à l'administration pour récupérer votre convention."),
          ),
        ),
      ],
    );
  }

  Widget _buildRefusedView(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.cancel, color: Colors.red, size: 100),
        const SizedBox(height: 20),
        const Text(
          "Statut : Refusé",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 20),
        const Text(
          "desole,votre demande de stage est refusé ! contacter ladministration de stage",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 50),
        const Text(
          "Contactez l'administration :",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        // Bouton en forme de téléphone
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Appel de l'administration : 76 123 456")),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.phone, color: Colors.white, size: 40),
          ),
        ),
      ],
    );
  }
}
