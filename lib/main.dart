import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Harita Oyunu',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng _currentPosition =
      const LatLng(41.0082, 28.9784); // İstanbul başlangıç noktası
  final LatLng _targetPosition =
      const LatLng(41.015137, 28.979530); // Hedef nokta
  final double _stepSize = 0.0001; // Hareket mesafesi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Harita Oyunu')),
      body: Platform.isAndroid || Platform.isIOS
          ? Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15.0,
                  ),
                  markers: _createMarkers(),
                ),
                _buildControlButtons(),
              ],
            )
          : const Center(
              child: Text('Bu platformda harita desteği yok.'),
            ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Set<Marker> _createMarkers() {
    return {
      Marker(
        markerId: const MarkerId('currentPosition'),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('targetPosition'),
        position: _targetPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 50.0,
      left: 50.0,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: () => _moveMarker(0, _stepSize),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _moveMarker(-_stepSize, 0),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _moveMarker(_stepSize, 0),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            onPressed: () => _moveMarker(0, -_stepSize),
          ),
        ],
      ),
    );
  }

  void _moveMarker(double dx, double dy) {
    setState(() {
      _currentPosition = LatLng(
        _currentPosition.latitude + dy,
        _currentPosition.longitude + dx,
      );

      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );

      _checkIfTargetReached();
    });
  }

  void _checkIfTargetReached() {
    double distance = _calculateDistance(
      _currentPosition.latitude,
      _currentPosition.longitude,
      _targetPosition.latitude,
      _targetPosition.longitude,
    );

    if (distance < 0.0001) {
      _showWinningDialog();
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    double p = 0.017453292519943295;
    double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _showWinningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kazandınız!'),
        content: const Text('Hedefe ulaştınız.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentPosition =
                    const LatLng(41.0082, 28.9784); // Başlangıç noktasına dön
              });
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
