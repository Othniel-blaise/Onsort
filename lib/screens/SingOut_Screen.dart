import 'package:flutter/material.dart';
import 'package:onsortx/screens/SingIn_screen.dart';


class SingoutScreen extends StatefulWidget {
  @override
  _SingoutScreenState createState() => _SingoutScreenState();
}

class _SingoutScreenState extends State<SingoutScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Couleur crème/beige clair
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Espace en haut (réduit)
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                    // Icône cocktail
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE6B800), // Couleur dorée
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.local_bar_outlined,
                        color: Color(0xFFE6B800),
                        size: 30,
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                    // Titre SIGN IN
                    const Text(
                      'SIGN OUT',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 2,
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                    // Champ Email
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Nom complet',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email ou téléphone',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Champ Mot de passe
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Mot de passe',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey,
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                    // Bouton Connexion
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          // Logique de connexion
                          _handleLogin();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFE6B800), // Couleur dorée
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'S\'inscrire',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("ou s'incrire via :",
                        style: TextStyle(color: Colors.black54)),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Image.asset(
                              "assets/google.png", // Mets ton logo Google ici
                              height: 20,
                            ),
                            label: const Text("Google"),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Facebook
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Image.asset(
                              "assets/facebook.png", // Mets ton logo Facebook ici
                              height: 20,
                            ),
                            label: const Text("Facebook"),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(),
                    Text("Vous avez déjà un compte ? "),
                    TextButton(onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context)=>SingInScreen()));
                    } ,
 
                    child: Text("CONNEXION"))




                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    // Validation basique
    if (_emailController.text.isEmpty) {
      _showSnackBar('Veuillez entrer votre email ou téléphone');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showSnackBar('Veuillez entrer votre mot de passe');
      return;
    }

    // Ici vous pouvez ajouter votre logique de connexion
    // Par exemple, appel API, Firebase Auth, etc.
    print('Email: ${_emailController.text}');
    print('Password: ${_passwordController.text}');

    _showSnackBar('Tentative de connexion...');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE6B800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
