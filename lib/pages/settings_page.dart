import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/theme_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // On récupère l'instance de ThemeSettings pour appliquer les changements
    final settings = Provider.of<ThemeSettings>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        backgroundColor: settings.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dark Mode
          SwitchListTile(
            title: const Text("Mode Sombre (Dark Mode)"),
            secondary: Icon(Icons.dark_mode, color: settings.primaryColor),
            value: settings.isDarkMode,
            onChanged: (val) {
              settings.toggleDarkMode(val);
            },
          ),
          const Divider(),
          
          // Langues
          ListTile(
            title: const Text("Changer la langue"),
            subtitle: Text(settings.language),
            leading: Icon(Icons.language, color: settings.primaryColor),
            onTap: () => _showLanguageDialog(settings),
          ),
          const Divider(),

          // Couleurs des icônes (Thème Primaire)
          ListTile(
            title: const Text("Couleur principale (Icônes)"),
            leading: Icon(Icons.palette, color: settings.primaryColor),
            trailing: CircleAvatar(backgroundColor: settings.primaryColor, radius: 15),
            onTap: () => _showColorPicker(context, settings, 'icon'),
          ),
          const Divider(),

          // Couleurs d'écriture
          ListTile(
            title: const Text("Couleur d'écriture"),
            leading: Icon(Icons.font_download, color: settings.textColor),
            trailing: CircleAvatar(backgroundColor: settings.textColor, radius: 15),
            onTap: () => _showColorPicker(context, settings, 'text'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(ThemeSettings settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choisir la langue"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _langOption(context, settings, "Français"),
              _langOption(context, settings, "English"),
              _langOption(context, settings, "Arabe"),
            ],
          ),
        );
      },
    );
  }

  Widget _langOption(BuildContext context, ThemeSettings settings, String lang) {
    return ListTile(
      title: Text(lang),
      onTap: () {
        settings.setLanguage(lang);
        Navigator.pop(context);
      },
    );
  }

  void _showColorPicker(BuildContext context, ThemeSettings settings, String type) {
    final List<Color> colors = [
      kPrimaryBlue, 
      Colors.red, 
      Colors.green, 
      Colors.orange, 
      Colors.purple, 
      Colors.black,
      Colors.pink,
      Colors.teal,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choisir la couleur ${type == 'icon' ? 'principale' : 'du texte'}"),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: colors.map((c) => GestureDetector(
              onTap: () {
                if (type == 'icon') {
                  settings.setPrimaryColor(c);
                } else {
                  settings.setTextColor(c);
                }
                Navigator.pop(context);
              },
              child: CircleAvatar(backgroundColor: c),
            )).toList(),
          ),
        );
      },
    );
  }
}
