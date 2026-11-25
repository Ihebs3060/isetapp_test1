import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const IsetApp());
}

class IsetApp extends StatelessWidget {
  const IsetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ISET Sidi Bouzid',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: kPrimaryBlue,
      ),
      home: const SelectionPage(),
    );
  }
}

const Color kPrimaryBlue = Color(0xFF005B7F);

String getFormattedDate() {
  final now = DateTime.now();
  final months = [
    'Janvier','Février','Mars','Avril','Mai','Juin',
    'Juillet','Août','Septembre','Octobre','Novembre','Décembre'
  ];
  return "${now.day} ${months[now.month - 1]} ${now.year}";
}

//////////////////// BOUTON ANIME ////////////////////

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isOutlined;
  final Color? color;
  final Color? textColor;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isOutlined = false,
    this.color,
    this.textColor,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0,
      upperBound: 0.05,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tapDown(TapDownDetails d) => _controller.forward();
  void _tapUp(TapUpDetails d) {
    _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.color ?? (widget.isOutlined ? Colors.white : Colors.white);

    final effectiveTextColor =
        widget.textColor ?? (widget.isOutlined ? Colors.white : kPrimaryBlue);

    return GestureDetector(
      onTapDown: _tapDown,
      onTapUp: _tapUp,
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: 1 - _controller.value,
        child: SizedBox(
          width: double.infinity,
          child: widget.isOutlined
              ? OutlinedButton(
            onPressed: widget.onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: effectiveColor, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(widget.text,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: effectiveTextColor)),
          )
              : ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: effectiveColor,
              foregroundColor: effectiveTextColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(widget.text,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

//////////////////// SELECTION ////////////////////

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBlue,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(getFormattedDate(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),

              const SizedBox(height: 30),

              const Text(
                "Bienvenue à l'Institut supérieur d'études technologiques",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white),
              ),

              const SizedBox(height: 30),

              /// ⚠️ Place ton logo ici :
              /// assets/images/logo.png
              Image.asset('assets/images/logo.png', height: 120),

              const SizedBox(height: 50),

              AnimatedButton(
                text: "Administratif / Prof",
                isOutlined: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                        const LoginPage(destination: ProfDashboard())),
                  );
                },
              ),

              const SizedBox(height: 15),

              AnimatedButton(
                text: "Étudiant",
                isOutlined: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                        const LoginPage(destination: EtudiantDashboard())),
                  );
                },
              ),

              const SizedBox(height: 15),

              AnimatedButton(
                text: "Visiteur",
                isOutlined: true,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const VisitorPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////// LOGIN ////////////////////

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
        title: Text(getFormattedDate()),
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
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(10),
                child: Image.asset('assets/images/logo.png'),
              ),

              const SizedBox(height: 45),

              _textField(
                controller: cinController,
                hint: "CIN (8 chiffres)",
                icon: Icons.badge,
                maxLength: 8,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                action: TextInputAction.next,
              ),

              const SizedBox(height: 18),

              _textField(
                controller: passController,
                hint: "Mot de passe (5 caractères)",
                icon: Icons.lock,
                isPassword: true,
                maxLength: 5,
                action: TextInputAction.done,
              ),

              const SizedBox(height: 35),

              AnimatedButton(
                text: "SE CONNECTER",
                onPressed: () {
                  if (cinController.text.length != 8 ||
                      passController.text.length != 5) {
                    showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(
                          title: Text("Informations incomplètes"),
                          content: Text(
                              "• CIN : 8 chiffres\n• Mot de passe : 5 caractères"),
                        ));
                  } else {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => widget.destination));
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
    TextInputAction? action,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? hidePassword : false,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: action,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        counterStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
              hidePassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.white),
          onPressed: () => setState(() => hidePassword = !hidePassword),
        )
            : null,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withAlpha(25),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }
}

//////////////////// DASHBOARDS SIMPLES ////////////////////

class ProfDashboard extends StatelessWidget {
  const ProfDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return _simplePage(context, "Espace Enseignant");
  }
}

class EtudiantDashboard extends StatelessWidget {
  const EtudiantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return _simplePage(context, "Espace Étudiant");
  }
}

class VisitorPage extends StatelessWidget {
  const VisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _simplePage(context, "Espace Visiteur");
  }
}

Widget _simplePage(BuildContext context, String title) {
  return Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Text(getFormattedDate(), style: const TextStyle(fontSize: 14))
        ],
      ),
      backgroundColor: kPrimaryBlue,
      foregroundColor: Colors.white,
    ),
    body: Center(child: Text(title)),
  );
}
