import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Changez cette URL selon votre configuration WAMP
  static const String baseUrl = 'http://192.168.1.40/onsortx_api/api';
  // Pour un émulateur Android : 'http://10.0.2.2/onsortx_api/api'
  // Pour un appareil physique : 'http://192.168.1.XXX/onsortx_api/api'
  
  // Inscription utilisateur
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      print('Tentative d\'inscription pour: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );
      
      print('Code de réponse: ${response.statusCode}');
      print('Corps de réponse: ${response.body}');
      
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      return {
        'success': response.statusCode == 201,
        'message': data['message'] ?? 'Erreur inconnue',
        'data': data,
      };
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
        'data': null,
      };
    }
  }
  
  // Connexion utilisateur
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('Tentative de connexion pour: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      print('Code de réponse: ${response.statusCode}');
      print('Corps de réponse: ${response.body}');
      
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Erreur inconnue',
        'user': data['user'],
        'session_token': data['session_token'],
      };
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
        'user': null,
        'session_token': null,
      };
    }
  }
  
  // Tester la connexion API
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/register.php'),
      );
      return response.statusCode == 405; // Méthode non autorisée = serveur fonctionne
    } catch (e) {
      print('Erreur de test de connexion: $e');
      return false;
    }
  }
}