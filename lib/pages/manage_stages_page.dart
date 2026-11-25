import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_theme.dart';

class ManageStagesPage extends StatefulWidget {
  const ManageStagesPage({super.key});

  @override
  State<ManageStagesPage> createState() => _ManageStagesPageState();
}

class _ManageStagesPageState extends State<ManageStagesPage> {
  final _supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> _stagesStream() {
    return _supabase
        .from('stages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await _supabase
          .from('stages')
          .update({'statut': newStatus})
          .eq('id', id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Statut mis à jour : $newStatus")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Stages"),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stagesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryBlue));
          }

          final stages = snapshot.data!;
          if (stages.isEmpty) {
            return const Center(child: Text("Aucune demande de stage"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final stage = stages[index];
              final String status = stage['statut'] ?? 'pending';
              
              Color statusColor = Colors.orange;
              if (status == 'accepted') statusColor = Colors.green;
              if (status == 'refused') statusColor = Colors.red;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stage['nom_etudiant'] ?? 'Étudiant inconnu',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("Entreprise: ${stage['entreprise']}"),
                      Text("Période: ${stage['periode']}"),
                      const SizedBox(height: 15),
                      if (stage['document_url'] != null)
                        TextButton.icon(
                          onPressed: () {
                            // Ici on pourrait ouvrir l'URL dans un navigateur
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ouverture du document... (Simulation)")),
                            );
                          },
                          icon: const Icon(Icons.file_present, color: kPrimaryBlue),
                          label: const Text("Voir le document"),
                        ),
                      const Divider(),
                      if (status == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => _updateStatus(stage['id'], 'refused'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              child: const Text("REFUSER"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _updateStatus(stage['id'], 'accepted'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              child: const Text("ACCEPTER"),
                            ),
                          ],
                        )
                      else
                        Center(
                          child: Text(
                            "Traitée le ${stage['created_at'].toString().substring(0, 10)}",
                            style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
