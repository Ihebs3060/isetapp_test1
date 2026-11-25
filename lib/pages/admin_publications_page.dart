import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_theme.dart';
import '../data/publications_supabase.dart';
import '../widgets/animated_button.dart';

/// Espace admin : publier des posts type Facebook (publication ou actualité) avec choix de photo.
class AdminPublicationsPage extends StatefulWidget {
  const AdminPublicationsPage({super.key});

  @override
  State<AdminPublicationsPage> createState() => _AdminPublicationsPageState();
}

class _AdminPublicationsPageState extends State<AdminPublicationsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _contenuController = TextEditingController();

  bool _isNews = false;
  bool _isSaving = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _posts = [];
  bool _loadingPosts = true;
  String? _postsError;
  bool _tableMissing = false;

  @override
  void initState() {
    super.initState();
    _reloadPosts();
  }

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _reloadPosts() async {
    setState(() {
      _loadingPosts = true;
      _postsError = null;
      _tableMissing = false;
    });
    try {
      final rows = await fetchPublications();
      if (!mounted) return;
      setState(() {
        _posts = rows;
        _loadingPosts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPosts = false;
        _tableMissing = isMissingTableOrSchemaError(e);
        _postsError = e is PostgrestException ? e.message : e.toString();
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = 'pub_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'publications/$fileName';
      
      await Supabase.instance.client.storage
          .from('publications') // Assurez-vous d'avoir créé ce bucket dans Supabase
          .upload(path, imageFile);

      return Supabase.instance.client.storage
          .from('publications')
          .getPublicUrl(path);
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      await Supabase.instance.client.from(kPublicationsTable).insert({
        'type': _isNews ? 'news' : 'publication',
        'titre': _titreController.text.trim(),
        'contenu': _contenuController.text.trim(),
        'image_url': imageUrl,
      });

      if (!mounted) return;
      _titreController.clear();
      _contenuController.clear();
      setState(() => _selectedImage = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publication enregistrée')),
      );
      await _reloadPosts();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      final missing = isMissingTableOrSchemaError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            missing
                ? 'Table absente : exécutez le script SQL dans Supabase.'
                : e.message,
          ),
        ),
      );
      if (missing) await _reloadPosts();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'enregistrement')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publications & actualités'),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        color: kPrimaryBlue,
        onRefresh: _reloadPosts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nouvelle publication',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Publication'),
                              selected: !_isNews,
                              onSelected: (v) { if (v) setState(() => _isNews = false); },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Actualité'),
                              selected: _isNews,
                              onSelected: (v) { if (v) setState(() => _isNews = true); },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titreController,
                          decoration: InputDecoration(
                            labelText: 'Titre',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.title, color: kPrimaryBlue),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _contenuController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Texte',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.article_outlined, color: kPrimaryBlue),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Contenu requis' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Sélecteur d'image
                        const Text("Ajouter une image", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text("Cliquez pour choisir une photo", style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                          ),
                        ),
                        if (_selectedImage != null)
                          TextButton.icon(
                            onPressed: () => setState(() => _selectedImage = null),
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            label: const Text("Supprimer la photo", style: TextStyle(color: Colors.red)),
                          ),
                        
                        const SizedBox(height: 20),
                        _isSaving
                            ? const Center(child: CircularProgressIndicator(color: kPrimaryBlue))
                            : AnimatedButton(text: 'PUBLIER', onPressed: _publish),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Aperçu des publications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (_loadingPosts)
                  const Center(child: CircularProgressIndicator(color: kPrimaryBlue))
                else
                  ..._posts.map((p) => _AdminPostPreview(p)).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminPostPreview extends StatelessWidget {
  final Map<String, dynamic> row;
  const _AdminPostPreview(this.row);

  @override
  Widget build(BuildContext context) {
    final imageUrl = row['image_url']?.toString();
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => const SizedBox()),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row['titre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(row['contenu'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
