import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_theme.dart';
import '../widgets/animated_button.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _cinController = TextEditingController();
  final _telController = TextEditingController();

  String _selectedClasse = 'RSI 2';
  final List<String> _classes = ['RSI 1', 'RSI 2', 'MDW 1', 'MDW 2'];
  bool _isSaving = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _dateNaissanceController.dispose();
    _cinController.dispose();
    _telController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initialDate = DateTime(2003, 1, 1);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dateNaissanceController.text =
            '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
      });
    }
  }

  String _toSqlDate(String displayDate) {
    final parts = displayDate.split('/');
    if (parts.length != 3) return displayDate;
    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];
    return '$year-$month-$day';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);

    try {
      await Supabase.instance.client.from('etudiants').insert({
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'date_naissance': _toSqlDate(_dateNaissanceController.text.trim()),
        'cin': _cinController.text.trim(),
        'telephone': _telController.text.trim(),
        'classe': _selectedClasse,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Etudiant ajoute avec succes')),
      );
      Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur base de donnees: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l ajout de l etudiant')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter Étudiant'),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTextField(
                controller: _nomController,
                label: 'Nom',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir le nom';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _prenomController,
                label: 'Prénom',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir le prénom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateNaissanceController,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  labelText: 'Date de naissance',
                  prefixIcon: const Icon(Icons.cake, color: kPrimaryBlue),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _pickDate,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez choisir la date de naissance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _cinController,
                label: 'CIN',
                icon: Icons.badge,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.length != 8 || int.tryParse(v) == null) {
                    return 'Le CIN doit contenir 8 chiffres';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _telController,
                label: 'N° de téléphone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.length < 8 || int.tryParse(v.replaceAll(' ', '')) == null) {
                    return 'Numéro de téléphone invalide';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedClasse,
                items: _classes
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Classe',
                  prefixIcon: const Icon(Icons.class_, color: kPrimaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedClasse = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              _isSaving
                  ? const CircularProgressIndicator(color: kPrimaryBlue)
                  : AnimatedButton(
                      text: 'AJOUTER ETUDIANT',
                      onPressed: _submit,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: kPrimaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
