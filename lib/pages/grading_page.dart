import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_theme.dart';
import '../widgets/animated_button.dart';

class GradingPage extends StatefulWidget {
  const GradingPage({super.key});

  @override
  State<GradingPage> createState() => _GradingPageState();
}

class _GradingPageState extends State<GradingPage> {
  final Map<String, TextEditingController> _dsControllers = {};
  final Map<String, TextEditingController> _examenControllers = {};

  Stream<List<Map<String, dynamic>>> _studentsStream() {
    return Supabase.instance.client
        .from('etudiants')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  @override
  void dispose() {
    for (var c in _dsControllers.values) c.dispose();
    for (var c in _examenControllers.values) c.dispose();
    super.dispose();
  }

  Color getGradeColor(String value) {
    double? grade = double.tryParse(value);
    if (grade == null) return Colors.black;
    if (grade < 10) return Colors.red;
    if (grade <= 15) return Colors.orange;
    return Colors.green;
  }

  Widget _gradeField(TextEditingController controller, String label) {
    return SizedBox(
      width: 70,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) {
          if (value.isNotEmpty) {
            double? grade = double.tryParse(value);
            if (grade != null && grade > 20) {
              controller.text = "20";
              controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length));
            }
          }
          setState(() {});
        },
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: getGradeColor(controller.text),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saisie des Notes"),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _studentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur lors du chargement des etudiants"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryBlue));
          }

          final students = snapshot.data!;
          if (students.isEmpty) {
            return const Center(child: Text("Aucun etudiant ajoute pour le moment"));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final studentId = student['id'].toString();
                    final fullName = '${student['prenom'] ?? ''} ${student['nom'] ?? ''}'.trim();

                    // Initialiser les contrôleurs s'ils n'existent pas
                    _dsControllers.putIfAbsent(studentId, () => TextEditingController());
                    _examenControllers.putIfAbsent(studentId, () => TextEditingController());

                    return Card(
                      child: ListTile(
                        title: Text(fullName.isEmpty ? '-' : fullName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text('Classe: ${student['classe'] ?? '-'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _gradeField(_dsControllers[studentId]!, "DS"),
                            const SizedBox(width: 10),
                            _gradeField(_examenControllers[studentId]!, "Examen"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AnimatedButton(
                      text: "PARTAGER AVEC L'ADMINISTRATION",
                      color: Colors.orange,
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Notes envoyées à l'administration")));
                      },
                    ),
                    const SizedBox(height: 10),
                    AnimatedButton(
                      text: "PARTAGER AVEC LES ÉTUDIANTS",
                      color: Colors.pink,
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Notes envoyées individuellement aux étudiants")));
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
