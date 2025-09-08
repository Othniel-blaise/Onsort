import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onsortx/screens/Singout_Screen.dart';

void main() {
  runApp(const Onsort());
}

class Onsort extends StatelessWidget {
  const Onsort({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnSort Test',
      home: const SimpleSplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimpleSplashScreen extends StatefulWidget {
  const SimpleSplashScreen({Key? key}) : super(key: key);

  @override
  State<SimpleSplashScreen> createState() => _SimpleSplashScreenState();
}

class _SimpleSplashScreenState extends State<SimpleSplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Configuration de la barre de statut
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    _navigateToSignout();
  }

  void _navigateToSignout() {
    // Navigation après 0.5 seconde (500 millisecondes)
    Future.delayed(const Duration(milliseconds: 6000), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SingoutScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1), // Indigo
              Color(0xFF8B5CF6), // Violet
              Color(0xFFEC4899), // Pink
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo simple
            Icon(
              Icons.arrow_forward,
              size: 80,
              color: Colors.white,
            ),
            
            SizedBox(height: 20),
            
            // Nom de l'app
            Text(
              'OnSort',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            
            SizedBox(height: 8),
            
            // Sous-titre
            Text(
              'Votre application de tri intelligent',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}