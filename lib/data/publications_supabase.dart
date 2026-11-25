import 'package:supabase_flutter/supabase_flutter.dart';

const String kPublicationsTable = 'publications_actualites';

/// Liste des publications (plus récentes en premier).
Future<List<Map<String, dynamic>>> fetchPublications() async {
  final response = await Supabase.instance.client
      .from(kPublicationsTable)
      .select()
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response as List);
}

bool isMissingTableOrSchemaError(Object error) {
  if (error is PostgrestException) {
    final code = error.code;
    final msg = error.message.toLowerCase();
    if (code == 'PGRST205') return true;
    if (msg.contains('schema cache') || msg.contains('could not find the table')) {
      return true;
    }
  }
  final s = error.toString().toLowerCase();
  return s.contains('pgrst205') || s.contains('could not find the table');
}
