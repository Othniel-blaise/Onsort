import 'package:flutter/material.dart';
import 'package:onsortx/screens/SingIn_screen.dart';
import 'package:onsortx/services/api_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE6B800), width: 2),
                ),
                child: const Icon(Icons.local_bar_outlined, color: Color(0xFFE6B800), size: 30),
              ),
              
              const SizedBox(height: 30),
              
              // Titre
              const Text(
                'INSCRIPTION',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              
              const SizedBox(height: 40),
              
              // Nom complet
              _buildTextField(
                controller: _fullNameController,
                hintText: 'Nom complet',
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 16),
              
              // Email
              _buildTextField(
                controller: _emailController,
                hintText: 'Email',
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 16),
              
              // Téléphone (optionnel)
              _buildTextField(
                controller: _phoneController,
                hintText: 'Téléphone (optionnel)',
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 16),
              
              // Mot de passe
              _buildTextField(
                controller: _passwordController,
                hintText: 'Mot de passe',
                obscureText: !_isPasswordVisible,
                enabled: !_isLoading,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Bouton Inscription
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6B800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('S\'INSCRIRE', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Inscription via réseaux sociaux
              const Text("ou s'inscrire via :", style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showSnackBar('Fonctionnalité bientôt disponible'),
                      icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                      label: const Text("Google"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showSnackBar('Fonctionnalité bientôt disponible'),
                      icon: const Icon(Icons.facebook, color: Colors.blue),
                      label: const Text("Facebook"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Lien connexion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Déjà un compte ? "),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen())),
                    child: const Text("SE CONNECTER", style: TextStyle(color: Color(0xFFE6B800))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (_fullNameController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty || 
        _passwordController.text.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs obligatoires');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.registerUser(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );

      if (result['success']) {
        _showSnackBar('Inscription réussie !');
        // Retourner à l'écran de connexion après inscription réussie
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
      } else {
        _showSnackBar(result['message'] ?? 'Erreur lors de l\'inscription');
      }
    } catch (e) {
      _showSnackBar('Erreur : $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFE6B800)),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}