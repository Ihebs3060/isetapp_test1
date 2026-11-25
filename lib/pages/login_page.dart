import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';
import '../widgets/animated_button.dart';
import 'prof_dashboard.dart';
import 'etudiant_dashboard.dart';

class LoginPage extends StatefulWidget {
  final Widget destination;

  const LoginPage({super.key, required this.destination});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final cinController = TextEditingController();
  final passController = TextEditingController();
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          getFormattedDate(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
          child: Column(
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset('lib/images/logo.png'),
              ),
              const SizedBox(height: 45),
              _textField(
                controller: cinController,
                hint: "CIN (8 chiffres)",
                icon: Icons.badge,
                maxLength: 8,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 18),
              _textField(
                controller: passController,
                hint: "Mot de passe (5 caractères)",
                icon: Icons.lock,
                isPassword: true,
                maxLength: 5,
              ),
              const SizedBox(height: 35),
              AnimatedButton(
                text: "SE CONNECTER",
                onPressed: () {
                  if (cinController.text.length != 8 || passController.text.length != 5) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Informations incomplètes"),
                        content: const Text(
                          "Veuillez remplir correctement les champs :\n\n"
                          "• CIN : 8 chiffres requis\n"
                          "• Mot de passe : 5 caractères requis"
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => widget.destination),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? hidePassword : false,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        counterStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  hidePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() => hidePassword = !hidePassword);
                },
              )
            : null,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withAlpha(25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
