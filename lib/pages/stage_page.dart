import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_theme.dart';
import '../widgets/animated_button.dart';

class StagePage extends StatefulWidget {
  const StagePage({super.key});

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  final _formKey = GlobalKey<FormState>();
  final _entrepriseController = TextEditingController();
  final _periodeController = TextEditingController();
  File? _documentImage;
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitted = false;
  bool _isUploading = false;
  String _status = 'pending'; 

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _documentImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _sendDemande() async {
    if (!_formKey.currentState!.validate() || _documentImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs et ajouter une photo")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Upload de la photo dans le Storage Supabase
      final String fileName = 'stage_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage
          .from('stages') // Assurez-vous que ce bucket existe et est public
          .upload(fileName, _documentImage!);

      final String imageUrl = Supabase.instance.client.storage
          .from('stages')
          .getPublicUrl(fileName);

      // 2. Enregistrement des données dans la table 'stages'
      await Supabase.instance.client.from('stages').insert({
        'nom_etudiant': 'Iheb Ben Abdallah', // Idéalement dynamique selon l'utilisateur connecté
        'entreprise': _entrepriseController.text.trim(),
        'periode': _periodeController.text.trim(),
        'document_url': imageUrl,
        'statut': 'pending',
      });

      setState(() {
        _isSubmitted = true;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Demande envoyée avec succès !")),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'envoi : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion de Stage"),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isSubmitted ? _buildStatusView() : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Remplissez les informations pour votre demande de stage",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryBlue),
            ),
            const SizedBox(height: 25),
            _buildTextField(_entrepriseController, "Nom de l'entreprise", Icons.business),
            const SizedBox(height: 15),
            _buildTextField(_periodeController, "Période (ex: Janvier - Février)", Icons.date_range),
            const SizedBox(height: 25),
            const Text(
              "Document de stage (Photo de l'attestation/demande)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                ),
                child: _documentImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_documentImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: kPrimaryBlue.withAlpha(150)),
                          const SizedBox(height: 10),
                          const Text("Cliquez pour ajouter une photo", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            if (_documentImage != null)
              TextButton.icon(
                onPressed: () => setState(() => _documentImage = null),
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                label: const Text("Supprimer la photo", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 40),
            _isUploading 
              ? const Center(child: CircularProgressIndicator(color: kPrimaryBlue))
              : AnimatedButton(
                  text: "ENVOYER LA DEMANDE",
                  onPressed: _sendDemande,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusView() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_status == 'pending')
              _buildPendingContent()
            else if (_status == 'accepted')
              _buildAcceptedContent()
            else
              _buildRefusedContent(),
            
            const SizedBox(height: 40),
            
            TextButton(
              onPressed: () => setState(() => _isSubmitted = false),
              child: const Text("RETOURNER AU FORMULAIRE", style: TextStyle(color: kPrimaryBlue)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingContent() {
    return Column(
      children: [
        const Icon(Icons.hourglass_empty, color: Colors.orange, size: 100),
        const SizedBox(height: 20),
        const Text(
          "Demande envoyée",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const SizedBox(height: 20),
        const Text(
          "Votre demande est actuellement en cours d'étude par l'administration.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        const Text(
          "Veuillez patienter pour la réponse définitive.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAcceptedContent() {
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

  Widget _buildRefusedContent() {
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kPrimaryBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez remplir ce champ';
        }
        return null;
      },
    );
  }
}
