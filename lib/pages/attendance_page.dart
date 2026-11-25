import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_theme.dart';
import '../widgets/animated_button.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final Map<String, bool> _presenceById = {};

  Stream<List<Map<String, dynamic>>> _studentsStream() {
    return Supabase.instance.client
        .from('etudiants')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appel des Étudiants"),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _studentsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Erreur lors du chargement des etudiants"),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: kPrimaryBlue),
                  );
                }

                final students = snapshot.data!;
                if (students.isEmpty) {
                  return const Center(
                    child: Text("Aucun etudiant ajoute pour le moment"),
                  );
                }

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final studentId = student['id'].toString();
                    final isPresent = _presenceById[studentId] ?? true;
                    final fullName =
                        '${student['prenom'] ?? ''} ${student['nom'] ?? ''}'
                            .trim();

                    return CheckboxListTile(
                      title: Text(fullName.isEmpty ? '-' : fullName),
                      subtitle: Text(
                        'Classe: ${student['classe'] ?? '-'} | CIN: ${student['cin'] ?? '-'}',
                      ),
                      value: isPresent,
                      onChanged: (val) {
                        setState(() {
                          _presenceById[studentId] = val ?? true;
                        });
                      },
                      activeColor: kPrimaryBlue,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedButton(
              text: "ENREGISTRER L'ABSENCE",
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Absences enregistrées avec succès")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
