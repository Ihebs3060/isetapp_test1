import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class AbsencesPage extends StatelessWidget {
  const AbsencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulation des données d'absences
    // Structure: Jour -> [Séance 1, Séance 2, Séance 3, Séance 4]
    final Map<String, List<Map<String, dynamic>>> schedule = {
      'Lundi': [
        {'matiere': 'Algorithmique', 'absent': false},
        {'matiere': 'Réseaux', 'absent': true},
        {'matiere': 'Anglais', 'absent': false},
        {'matiere': 'Mathématiques', 'absent': false},
      ],
      'Mardi': [
        {'matiere': 'Base de données', 'absent': true},
        {'matiere': 'Base de données', 'absent': true},
        {'matiere': 'Développement Web', 'absent': false},
        {'matiere': 'Atelier RSI', 'absent': false},
      ],
      'Mercredi': [
        {'matiere': 'Système Exploitation', 'absent': false},
        {'matiere': 'Système Exploitation', 'absent': false},
        {'matiere': 'Algorithmique', 'absent': true},
        {'matiere': 'Réseaux', 'absent': false},
      ],
      'Jeudi': [
        {'matiere': 'Développement Mobile', 'absent': false},
        {'matiere': 'Développement Mobile', 'absent': false},
        {'matiere': 'Culture Entrep.', 'absent': false},
        {'matiere': 'Atelier RSI', 'absent': true},
      ],
      'Vendredi': [
        {'matiere': 'Algorithmique', 'absent': true},
        {'matiere': 'Algorithmique', 'absent': true},
        {'matiere': 'Base de données', 'absent': true},
        {'matiere': 'Base de données', 'absent': true},
      ],
    };

    // Calcul du total par matière pour l'alerte
    Map<String, int> totalAbsences = {};
    schedule.forEach((jour, seances) {
      for (var seance in seances) {
        if (seance['absent']) {
          String matiere = seance['matiere'];
          totalAbsences[matiere] = (totalAbsences[matiere] ?? 0) + 1;
        }
      }
    });

    List<String> matieresCritiques = [];
    totalAbsences.forEach((matiere, count) {
      if (count >= 4) {
        matieresCritiques.add(matiere);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Suivi des Absences"),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Affichage des alertes si nécessaire
            if (matieresCritiques.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 10),
                        Text("ALERTE ABSENCES", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Vous avez dépassé le seuil d'absences (4+) dans les matières suivantes :", style: TextStyle(color: Colors.black87)),
                    const SizedBox(height: 5),
                    ...matieresCritiques.map((m) => Text("• $m", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                    const SizedBox(height: 5),
                    const Text("Risque d'élimination ou passage en conseil de discipline.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red)),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: MaterialStateProperty.all(kPrimaryBlue.withOpacity(0.1)),
                  columns: const [
                    DataColumn(label: Text('Jour', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('S1', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('S2', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('S3', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('S4', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: schedule.entries.map((entry) {
                    return DataRow(
                      cells: [
                        DataCell(Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold))),
                        ...entry.value.map((seance) {
                          return DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(seance['matiere'], style: const TextStyle(fontSize: 10)),
                                if (seance['absent'])
                                  const Icon(Icons.close, color: Colors.red, size: 20)
                                else
                                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Légende: S1 à S4 représentent les séances de la journée.\nLa croix rouge indique une absence enregistrée.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
