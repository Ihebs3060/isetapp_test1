import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../data/publications_supabase.dart';

/// Fil d'actualités / événements pour l'espace étudiant (lecture Supabase).
class StudentEventsPage extends StatefulWidget {
  const StudentEventsPage({super.key});

  @override
  State<StudentEventsPage> createState() => _StudentEventsPageState();
}

class _StudentEventsPageState extends State<StudentEventsPage> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;
  String? _error;
  bool _tableMissing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _tableMissing = false;
    });
    try {
      final rows = await fetchPublications();
      if (!mounted) return;
      setState(() {
        _posts = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _tableMissing = isMissingTableOrSchemaError(e);
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Évènements & actualités'),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: kPrimaryBlue,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator(color: kPrimaryBlue)),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: _tableMissing ? Colors.orange.shade50 : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tableMissing
                        ? 'Configuration Supabase requise'
                        : 'Erreur de chargement',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_tableMissing)
                    const Text(
                      'La table publications_actualites n’existe pas encore. '
                      'Exécutez le script supabase/publications_actualites.sql dans le SQL Editor Supabase, puis actualisez.',
                    )
                  else
                    Text(_error!),
                  TextButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Aucune publication pour le moment.\nRevenez plus tard.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return _FeedCard(post: _posts[index]);
      },
    );
  }
}

class _FeedCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const _FeedCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final type = post['type']?.toString() ?? '';
    final titre = post['titre']?.toString() ?? '';
    final contenu = post['contenu']?.toString() ?? '';
    final imageUrl = post['image_url']?.toString();
    final created = post['created_at']?.toString() ?? '';
    final isNews = type == 'news';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: kPrimaryBlue.withValues(alpha: 0.15),
                  child: const Icon(Icons.school, color: kPrimaryBlue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Administration ISET',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        isNews ? 'Actualité' : 'Publication',
                        style: TextStyle(
                          fontSize: 12,
                          color: isNews ? Colors.deepOrange : Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _shortDate(created),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  contenu,
                  style: const TextStyle(fontSize: 15, height: 1.35),
                ),
              ],
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 80,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Text('Image indisponible'),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _shortDate(String raw) {
    if (raw.length < 10) return raw;
    return raw.substring(0, 10);
  }
}
