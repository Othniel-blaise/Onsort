import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onsortx/screens/Map_Screen.dart';
import 'package:onsortx/screens/SingnUp_Screen.dart';


void main() {
  runApp(const Onsort());
}

class Onsort extends StatelessWidget {
  const Onsort({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnSort Test',
      home: const MapScreen(),
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
    print('Splash screen initialisée');

    // Configuration de la barre de statut
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Délai avant navigation
    Future.delayed(Duration.zero, () async {
      // Attend 3 secondes pour montrer la splash screen
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignUpScreen(),
          ),
        );
        print('Navigation vers la page suivante');
      }
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A1A5C), // Violet foncé en haut
              Color(0xFF8B3F99), // Violet moyen
              Color(0xFFB85AA3), // Violet-rose
              Color(0xFFE91E63), // Rose magenta en bas
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo avec image
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE91E63), // Rose magenta
                      Color(0xFF9C27B0), // Violet
                      Color(0xFF3F51B5), // Bleu
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/logoOnSort.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Texte OnSort
              const Text(
                'OnSort',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),

              const SizedBox(height: 8),

              // Sous-titre
              const Text(
                'Votre application de Kiff intelligent',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 60),

              // Indicateur de chargement
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}