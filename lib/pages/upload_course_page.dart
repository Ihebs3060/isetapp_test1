import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../core/app_theme.dart';
import '../widgets/animated_button.dart';

class UploadCoursePage extends StatefulWidget {
  const UploadCoursePage({super.key});

  @override
  State<UploadCoursePage> createState() => _UploadCoursePageState();
}

class _UploadCoursePageState extends State<UploadCoursePage> {
  String? fileName;
  String selectedClass = "Les deux (RSI & MDW)";
  final List<String> classes = ["RSI", "MDW", "Les deux (RSI & MDW)"];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'pptx', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Envoyer un Cours"),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text("Configuration de l'envoi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              value: selectedClass,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Choisir la classe"),
              items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => selectedClass = val!),
            ),
            const SizedBox(height: 30),
            if (fileName != null)
              Card(child: ListTile(leading: const Icon(Icons.file_copy), title: Text(fileName!))),
            const SizedBox(height: 20),
            AnimatedButton(
              text: fileName == null ? "SÉLECTIONNER UN FICHIER" : "ENVOYER À $selectedClass",
              color: fileName == null ? kPrimaryBlue : Colors.green,
              textColor: Colors.white,
              onPressed: fileName == null ? _pickFile : () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Envoyé à $selectedClass")));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
