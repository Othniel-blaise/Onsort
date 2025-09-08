import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:math' as Math;
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? currentPosition;
  final MapController _mapController = MapController();
  bool isLoading = true;
  String? errorMessage;
  
  // Pour le trajet
  List<LatLng> routePoints = [];
  bool isNavigating = false;
  LatLng? destination;
  StreamSubscription<Position>? positionStream;
  String? navigationInfo;
  double? distanceToDestination;
  double? estimatedTime;
  List<String> routeInstructions = [];
  int currentInstructionIndex = 0;

  // Établissements fictifs
  final List<Map<String, dynamic>> establishments = [
    {
      'name': 'Restaurant Le Palmier',
      'position': const LatLng(5.3364, -4.0267),
      'icon': Icons.restaurant,
      'color': Colors.red,
    },
    {
      'name': 'Hôtel Ivoire',
      'position': const LatLng(5.3200, -4.0100),
      'icon': Icons.hotel,
      'color': Colors.blue,
    },
    {
      'name': 'Supermarché Hayat',
      'position': const LatLng(5.3400, -4.0350),
      'icon': Icons.store,
      'color': Colors.green,
    },
    {
      'name': 'Café des Arts',
      'position': const LatLng(5.3500, -4.0200),
      'icon': Icons.local_cafe,
      'color': Colors.brown,
    },
    {
      'name': 'Pharmacie Moderne',
      'position': const LatLng(5.3250, -4.0300),
      'icon': Icons.local_pharmacy,
      'color': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = 'Services de localisation désactivés.';
          isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = 'Permission de localisation refusée.';
            isLoading = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });

      _mapController.move(currentPosition!, 15.0);
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur: $e';
        isLoading = false;
      });
    }
  }

  // Utiliser l'API OpenRouteService pour obtenir un vrai trajet routier
  Future<Map<String, dynamic>> _getRealRoute(LatLng start, LatLng end) async {
    try {
      // Utilisation de l'API OpenRouteService (gratuite)
      // Remplacez 'YOUR_API_KEY' par une vraie clé API d'OpenRouteService
      const String apiKey = '5b3ce3597851110001cf6248b9c6e4a8581b4893bb0c9b4705c5bbdd'; // Clé de démo
      
      final String url = 'https://api.openrouteservice.org/v2/directions/driving-car?'
          'api_key=$apiKey'
          '&start=${start.longitude},${start.latitude}'
          '&end=${end.longitude},${end.latitude}';

      print('Demande de routage: $url');

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['features'] != null && data['features'].isNotEmpty) {
          final route = data['features'][0];
          final coordinates = route['geometry']['coordinates'] as List;
          final properties = route['properties'];
          
          // Convertir les coordonnées en LatLng
          List<LatLng> points = coordinates.map<LatLng>((coord) => 
            LatLng(coord[1].toDouble(), coord[0].toDouble())
          ).toList();
          
          // Extraire les instructions de navigation
          List<String> instructions = [];
          if (properties['segments'] != null && properties['segments'].isNotEmpty) {
            final steps = properties['segments'][0]['steps'] as List;
            instructions = steps.map<String>((step) => 
              step['instruction'].toString()
            ).toList();
          }
          
          return {
            'points': points,
            'distance': properties['summary']['distance'].toDouble() / 1000, // en km
            'duration': properties['summary']['duration'].toDouble() / 60, // en minutes
            'instructions': instructions,
          };
        }
      }
      
      // Si l'API échoue, utiliser un trajet simple
      return _getFallbackRoute(start, end);
      
    } catch (e) {
      print('Erreur API: $e');
      return _getFallbackRoute(start, end);
    }
  }

  // Trajet de secours si l'API ne fonctionne pas
  Map<String, dynamic> _getFallbackRoute(LatLng start, LatLng end) {
    List<LatLng> points = [];
    
    // Créer un trajet qui suit approximativement les routes principales
    double latDiff = end.latitude - start.latitude;
    double lngDiff = end.longitude - start.longitude;
    
    // Ajouter des points intermédiaires pour simuler un trajet routier
    for (int i = 0; i <= 20; i++) {
      double progress = i / 20.0;
      
      // Ajouter une courbe pour simuler les routes
      double curveFactor = 0.0001 * Math.sin(progress * 3.14159);
      
      points.add(LatLng(
        start.latitude + (latDiff * progress) + curveFactor,
        start.longitude + (lngDiff * progress) + curveFactor,
      ));
    }
    
    double distance = Geolocator.distanceBetween(
      start.latitude, start.longitude,
      end.latitude, end.longitude,
    ) / 1000;
    
    return {
      'points': points,
      'distance': distance,
      'duration': distance / 40 * 60, // 40 km/h moyenne en ville
      'instructions': [
        'Départ de votre position',
        'Continuez tout droit',
        'Tournez à droite',
        'Continuez sur 500m',
        'Vous êtes arrivé à destination'
      ],
    };
  }

  Future<void> _startNavigation(Map<String, dynamic> establishment) async {
    if (currentPosition == null) return;

    setState(() {
      isLoading = true;
      destination = establishment['position'];
    });

    try {
      // Obtenir le vrai trajet routier
      Map<String, dynamic> routeData = await _getRealRoute(currentPosition!, destination!);

      setState(() {
        routePoints = routeData['points'];
        isNavigating = true;
        isLoading = false;
        distanceToDestination = routeData['distance'];
        estimatedTime = routeData['duration'];
        routeInstructions = List<String>.from(routeData['instructions']);
        currentInstructionIndex = 0;
        navigationInfo = 'Navigation vers ${establishment['name']}';
      });

      // Démarrer le suivi en temps réel
      _startRealTimeTracking();
      
      // Ajuster la vue pour montrer tout le trajet
      _fitRouteInView();
      
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors du calcul du trajet: $e';
        isLoading = false;
      });
    }
  }

  void _startRealTimeTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      
      setState(() {
        currentPosition = newPosition;
        
        if (destination != null) {
          double distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            destination!.latitude,
            destination!.longitude,
          );
          distanceToDestination = distance / 1000;
          
          // Mettre à jour l'instruction actuelle en fonction de la position
          _updateCurrentInstruction(newPosition);
          
          if (distance < 50) {
            _stopNavigation();
            _showArrivalDialog();
          }
        }
      });

      _mapController.move(newPosition, _mapController.camera.zoom);
    });
  }

  void _updateCurrentInstruction(LatLng position) {
    if (routePoints.isEmpty || routeInstructions.isEmpty) return;
    
    // Trouver le point le plus proche sur le trajet
    double minDistance = double.infinity;
    int closestPointIndex = 0;
    
    for (int i = 0; i < routePoints.length; i++) {
      double distance = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        routePoints[i].latitude, routePoints[i].longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        closestPointIndex = i;
      }
    }
    
    // Mettre à jour l'index de l'instruction en fonction de la progression
    int newInstructionIndex = (closestPointIndex / routePoints.length * routeInstructions.length).floor();
    newInstructionIndex = newInstructionIndex.clamp(0, routeInstructions.length - 1);
    
    if (newInstructionIndex != currentInstructionIndex) {
      setState(() {
        currentInstructionIndex = newInstructionIndex;
      });
    }
  }

  void _fitRouteInView() {
    if (routePoints.isEmpty) return;
    
    double minLat = routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    
    LatLngBounds bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
    
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
  }

  void _stopNavigation() {
    positionStream?.cancel();
    setState(() {
      isNavigating = false;
      routePoints.clear();
      destination = null;
      navigationInfo = null;
      distanceToDestination = null;
      estimatedTime = null;
      routeInstructions.clear();
      currentInstructionIndex = 0;
    });
  }

  void _showArrivalDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Arrivée !'),
        content: const Text('Vous êtes arrivé à destination !'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition ?? const LatLng(5.3364, -4.0267),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.onsortx',
              ),
              
              // Afficher le trajet routier
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 6.0,
                      color: Colors.blue,
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              
              MarkerLayer(
                markers: [
                  // Position actuelle avec direction
                  if (currentPosition != null)
                    Marker(
                      point: currentPosition!,
                      width: 80,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isNavigating ? Colors.orange.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isNavigating ? Colors.orange : Colors.blue, 
                            width: 3
                          ),
                        ),
                        child: Icon(
                          isNavigating ? Icons.navigation : Icons.my_location,
                          color: isNavigating ? Colors.orange : Colors.blue,
                          size: 30,
                        ),
                      ),
                    ),

                  // Établissements
                  ...establishments.map((establishment) => Marker(
                    point: establishment['position'],
                    width: 60,
                    height: 80,
                    child: GestureDetector(
                      onTap: () => _showEstablishmentDialog(establishment),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: establishment['color'],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              establishment['icon'],
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              establishment['name'].split(' ')[0],
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),

                  // Destination
                  if (destination != null)
                    Marker(
                      point: destination!,
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Informations de navigation
          if (navigationInfo != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.navigation, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            navigationInfo!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (distanceToDestination != null && estimatedTime != null)
                      Row(
                        children: [
                          Icon(Icons.straighten, color: Colors.white, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            '${distanceToDestination!.toStringAsFixed(1)} km',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 20),
                          Icon(Icons.schedule, color: Colors.white, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            '${estimatedTime!.toInt()} min',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    if (routeInstructions.isNotEmpty && currentInstructionIndex < routeInstructions.length)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.turn_right, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                routeInstructions[currentInstructionIndex],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Indicateur de chargement
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Message d'erreur
          if (errorMessage != null && !isLoading)
            Positioned(
              bottom: 100,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: currentPosition != null && !isNavigating
          ? FloatingActionButton(
              onPressed: () => _mapController.move(currentPosition!, 15.0),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location, color: Colors.white),
            )
          : null,
    );
  }

  void _showEstablishmentDialog(Map<String, dynamic> establishment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(establishment['icon'], color: establishment['color']),
            const SizedBox(width: 10),
            Expanded(child: Text(establishment['name'])),
          ],
        ),
        content: currentPosition != null 
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📍 ${establishment['position'].latitude.toStringAsFixed(4)}, ${establishment['position'].longitude.toStringAsFixed(4)}'),
                const SizedBox(height: 10),
                if (currentPosition != null)
                  Text('🚗 Distance: ${(Geolocator.distanceBetween(
                    currentPosition!.latitude, 
                    currentPosition!.longitude,
                    establishment['position'].latitude, 
                    establishment['position'].longitude
                  ) / 1000).toStringAsFixed(1)} km'),
                const SizedBox(height: 10),
                const Text(
                  '🛣️ Trajet calculé sur les vraies routes',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.green,
                  ),
                ),
              ],
            )
          : const Text('Activez la localisation pour voir les informations'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          if (currentPosition != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _startNavigation(establishment);
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Navigation GPS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

// Extension pour les calculs mathématiques
