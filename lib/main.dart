import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'core/theme_settings.dart';
import 'pages/home_page.dart';

/// URL du projet Supabase
const String kSupabaseUrl = 'https://rwvkfaapeewecwkabmve.supabase.co';

/// Clé publique « anon »
const String kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3dmtmYWFwZWV3ZWN3a2FibXZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1MTE0NjAsImV4cCI6MjA5MjA4NzQ2MH0.gaWCflt3YC0JGpvx519dg9IiWXq4RkZ4V-qlg1RLaV8';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeSettings(),
      child: const IsetApp(),
    ),
  );
}

class IsetApp extends StatelessWidget {
  const IsetApp({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute les changements dans ThemeSettings
    final settings = Provider.of<ThemeSettings>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ISET Sidi Bouzid',
      // Utilisation du thème dynamique
      theme: settings.getTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
    );
  }
}
