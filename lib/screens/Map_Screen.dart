import 'dart:async';
import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? currentPosition;
  late final MapController _mapController;
  bool isLoading = true;
  String? errorMessage;
  bool isMapReady = false; // Important : état de la carte

  // Navigation
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
    {'name': 'Restaurant Le Palmier', 'position': const LatLng(5.3364, -4.0267), 'icon': Icons.restaurant, 'color': Colors.red},
    {'name': 'Hôtel Ivoire', 'position': const LatLng(5.3200, -4.0100), 'icon': Icons.hotel, 'color': Colors.blue},
    {'name': 'Supermarché Hayat', 'position': const LatLng(5.3400, -4.0350), 'icon': Icons.store, 'color': Colors.green},
    {'name': 'Café des Arts', 'position': const LatLng(5.3500, -4.0200), 'icon': Icons.local_cafe, 'color': Colors.brown},
    {'name': 'Pharmacie Moderne', 'position': const LatLng(5.3250, -4.0300), 'icon': Icons.local_pharmacy, 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeApp();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  // Initialisation de l'application
  Future<void> _initializeApp() async {
    await _getCurrentLocation();
  }

  // Callback appelé quand la carte est prête
  void _onMapReady() {
    setState(() {
      isMapReady = true;
    });
    
    // Maintenant que la carte est prête, on peut centrer sur la position
    if (currentPosition != null) {
      _moveToPosition(currentPosition!, 15.0);
    }
  }

  // Méthode sécurisée pour déplacer la carte
  void _moveToPosition(LatLng position, double zoom) {
    if (!isMapReady || !mounted) return;
    
    try {
      _mapController.move(position, zoom);
    } catch (e) {
      debugPrint('Erreur lors du déplacement de la carte: $e');
    }
  }

  // Méthode sécurisée pour ajuster la vue sur la route
  void _fitRouteToView() {
    if (!isMapReady || !mounted || routePoints.isEmpty) return;

    try {
      final bounds = LatLngBounds.fromPoints(routePoints);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
          maxZoom: 16,
        ),
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'ajustement de la vue: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = 'Les services de localisation sont désactivés.';
          isLoading = false;
        });
        return;
      }

      // Vérifier les permissions
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

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = 'Permissions de localisation définitivement refusées.';
          isLoading = false;
        });
        return;
      }

      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors de la localisation: $e';
        isLoading = false;
      });
    }
  }

  // API OpenRouteService
  Future<Map<String, dynamic>> _getRealRoute(LatLng start, LatLng end) async {
    try {
      const String apiKey = '5b3ce3597851110001cf6248b9c6e4a8581b4893bb0c9b4705c5bbdd';
      final String url =
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final route = data['features'][0];
          final coordinates = route['geometry']['coordinates'] as List;
          final properties = route['properties'];

          List<LatLng> points = coordinates
              .map<LatLng>((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();

          // Simplifier la route pour de meilleures performances
          points = _simplifyRoute(points, 200);

          List<String> instructions = [];
          if (properties['segments'] != null && properties['segments'].isNotEmpty) {
            final steps = properties['segments'][0]['steps'] as List;
            instructions = steps.map<String>((step) => step['instruction'].toString()).toList();
          }

          return {
            'points': points,
            'distance': properties['summary']['distance'].toDouble() / 1000,
            'duration': properties['summary']['duration'].toDouble() / 60,
            'instructions': instructions,
          };
        }
      }

      return _getFallbackRoute(start, end);
    } catch (e) {
      return _getFallbackRoute(start, end);
    }
  }

  Map<String, dynamic> _getFallbackRoute(LatLng start, LatLng end) {
    List<LatLng> points = [];
    double latDiff = end.latitude - start.latitude;
    double lngDiff = end.longitude - start.longitude;

    // Créer une route simple avec 20 points
    for (int i = 0; i <= 20; i++) {
      double progress = i / 20.0;
      double curveFactor = 0.0001 * Math.sin(progress * Math.pi);
      points.add(LatLng(
        start.latitude + latDiff * progress + curveFactor,
        start.longitude + lngDiff * progress + curveFactor,
      ));
    }

    double distance = Geolocator.distanceBetween(
      start.latitude, 
      start.longitude, 
      end.latitude, 
      end.longitude,
    ) / 1000;

    return {
      'points': points,
      'distance': distance,
      'duration': distance / 40 * 60, // Vitesse moyenne de 40 km/h
      'instructions': [
        'Départ de votre position',
        'Continuez tout droit',
        'Tournez à droite',
        'Continuez sur 500m',
        'Vous êtes arrivé à destination'
      ],
    };
  }

  List<LatLng> _simplifyRoute(List<LatLng> points, int maxPoints) {
    if (points.length <= maxPoints) return points;
    double step = points.length / maxPoints;
    return List.generate(maxPoints, (i) => points[(i * step).floor()]);
  }

  Future<void> _startNavigation(Map<String, dynamic> establishment) async {
    if (currentPosition == null) {
      _showMessage('Position actuelle non disponible');
      return;
    }

    setState(() {
      isLoading = true;
      destination = establishment['position'];
    });

    try {
      Map<String, dynamic> routeData = await _getRealRoute(currentPosition!, destination!);

      setState(() {
        routePoints = routeData['points'];
        distanceToDestination = routeData['distance'];
        estimatedTime = routeData['duration'];
        routeInstructions = List<String>.from(routeData['instructions']);
        currentInstructionIndex = 0;
        isNavigating = true;
        isLoading = false;
        navigationInfo = 'Navigation vers ${establishment['name']}';
      });

      _startRealTimeTracking();
      
      // Attendre un peu avant d'ajuster la vue
      await Future.delayed(const Duration(milliseconds: 500));
      _fitRouteToView();

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

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
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

          _updateCurrentInstruction(newPosition);

          // Arrivée à destination (50 mètres de tolérance)
          if (distance < 50) {
            _stopNavigation();
            _showArrivalDialog();
          }
        }
      });

      // Déplacer la carte vers la nouvelle position
      _moveToPosition(newPosition, isMapReady ? _mapController.camera.zoom : 15.0);
    });
  }

  void _updateCurrentInstruction(LatLng position) {
    if (routePoints.isEmpty || routeInstructions.isEmpty) return;
    
    int closestPointIndex = _findClosestPointIndex(position, routePoints);
    int newInstructionIndex = ((closestPointIndex / routePoints.length) * routeInstructions.length).floor();
    newInstructionIndex = newInstructionIndex.clamp(0, routeInstructions.length - 1);

    if (newInstructionIndex != currentInstructionIndex) {
      setState(() => currentInstructionIndex = newInstructionIndex);
    }
  }

  int _findClosestPointIndex(LatLng position, List<LatLng> points) {
    int closestIndex = 0;
    double minDistSquared = double.infinity;

    for (int i = 0; i < points.length; i++) {
      double dx = position.latitude - points[i].latitude;
      double dy = position.longitude - points[i].longitude;
      double distSquared = dx * dx + dy * dy;
      if (distSquared < minDistSquared) {
        minDistSquared = distSquared;
        closestIndex = i;
      }
    }

    return closestIndex;
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _centerOnCurrentPosition() {
    if (currentPosition != null && isMapReady) {
      _moveToPosition(currentPosition!, 15.0);
    } else {
      _showMessage('Position non disponible');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Chargement de la carte...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Écran d'erreur
    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  'Erreur',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      errorMessage = null;
                      isLoading = true;
                    });
                    _initializeApp();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Position par défaut si pas de position actuelle
    final initialCenter = currentPosition ?? const LatLng(5.3364, -4.0267);

    return Scaffold(
      body: Stack(
        children: [
          // Carte
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15.0,
              minZoom: 10.0,
              maxZoom: 18.0,
              onMapReady: _onMapReady, // Callback important
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Tuiles de carte
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mapapp',
              ),

              // Route de navigation
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

              // Marqueurs
              MarkerLayer(
                markers: [
                  // Position actuelle
                  if (currentPosition != null)
                    Marker(
                      point: currentPosition!,
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                  // Destination
                  if (destination != null)
                    Marker(
                      point: destination!,
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.place,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                  // Établissements
                  ...establishments.map(
                    (establishment) => Marker(
                      point: establishment['position'] as LatLng,
                      width: 120,
                      height: 70,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => _startNavigation(establishment),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: establishment['color'] as Color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                establishment['icon'] as IconData,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                establishment['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Interface de navigation
          if (isNavigating && navigationInfo != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // En-tête
                      Row(
                        children: [
                          const Icon(Icons.navigation, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              navigationInfo!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _stopNavigation,
                            icon: const Icon(Icons.close, color: Colors.red),
                            tooltip: 'Arrêter la navigation',
                          ),
                        ],
                      ),

                      // Informations de distance et temps
                      if (distanceToDestination != null && estimatedTime != null) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoChip(
                              Icons.straighten,
                              '${distanceToDestination!.toStringAsFixed(1)} km',
                              Colors.green,
                            ),
                            _buildInfoChip(
                              Icons.access_time,
                              '${estimatedTime!.toStringAsFixed(0)} min',
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],

                      // Instruction actuelle
                      if (routeInstructions.isNotEmpty && 
                          currentInstructionIndex < routeInstructions.length) ...[
                        const Divider(),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.turn_right,
                                color: Colors.blue,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  routeInstructions[currentInstructionIndex],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // Boutons flottants
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Centrer sur position
          FloatingActionButton(
            heroTag: "center",
            mini: true,
            onPressed: _centerOnCurrentPosition,
            tooltip: 'Centrer sur ma position',
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),

          // Arrêter navigation
          if (isNavigating)
            FloatingActionButton(
              heroTag: "stop",
              mini: true,
              backgroundColor: Colors.red,
              onPressed: _stopNavigation,
              tooltip: 'Arrêter la navigation',
              child: const Icon(Icons.stop, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}