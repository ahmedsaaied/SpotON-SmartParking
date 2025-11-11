// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRouteScreen extends StatefulWidget {
  const MapRouteScreen({super.key});

  @override
  State<MapRouteScreen> createState() => _MapRouteScreenState();
}

class _MapRouteScreenState extends State<MapRouteScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final List<LatLng> _fullRoute = [];
  final List<LatLng> _animatedRoute = [];
  Polyline? _animatedPolyline;
  Timer? _animationTimer;
  StreamSubscription<Position>? _positionStream;

  static const LatLng _garageLatLng = LatLng(30.095571, 31.374697);
  LatLng? _userLatLng;
  LatLng? _lastKnownUserLatLng;
  BitmapDescriptor? _garageIcon;

  String? _eta;
  String? _distance;

  @override
  void initState() {
    super.initState();
    _loadGarageIcon();
    _initLiveLocationTracking();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _loadGarageIcon() async {
    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/spoton.png',
    );
    setState(() {
      _garageIcon = icon;
    });
  }

  Future<void> _initLiveLocationTracking() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    final initialPosition = await Geolocator.getCurrentPosition();
    _userLatLng = LatLng(initialPosition.latitude, initialPosition.longitude);
    _lastKnownUserLatLng = _userLatLng;

    await _loadRoute();

    _positionStream = Geolocator.getPositionStream().listen((position) async {
      final newLatLng = LatLng(position.latitude, position.longitude);

      // If user strays more than 50 meters, recalculate
      if (Geolocator.distanceBetween(newLatLng.latitude, newLatLng.longitude,
              _lastKnownUserLatLng!.latitude, _lastKnownUserLatLng!.longitude) >
          50) {
        _lastKnownUserLatLng = newLatLng;
        _userLatLng = newLatLng;
        await _loadRoute();
      }

      // Smooth camera tracking
      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(newLatLng));

      // Zoom out if close to garage
      if (Geolocator.distanceBetween(newLatLng.latitude, newLatLng.longitude,
              _garageLatLng.latitude, _garageLatLng.longitude) <
          50) {
        controller.animateCamera(CameraUpdate.newLatLngZoom(_garageLatLng, 15));
      }
    });
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _loadRoute() async {
    if (_userLatLng == null) return;

    _animatedRoute.clear();
    _fullRoute.clear();
    _markers.clear();
    _animatedPolyline = null;

    final routePoints = await _getRoutePoints(_userLatLng!, _garageLatLng);
    if (routePoints.isEmpty || !mounted) return;

    _fullRoute.addAll(routePoints);
    _startPolylineAnimation();

    // Set markers
    _markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: _userLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: "You"),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId("garage"),
        position: _garageLatLng,
        icon: _garageIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(title: "AAST Garage"),
      ),
    );

    final controller = await _controller.future;
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        (_userLatLng!.latitude <= _garageLatLng.latitude)
            ? _userLatLng!.latitude
            : _garageLatLng.latitude,
        (_userLatLng!.longitude <= _garageLatLng.longitude)
            ? _userLatLng!.longitude
            : _garageLatLng.longitude,
      ),
      northeast: LatLng(
        (_userLatLng!.latitude > _garageLatLng.latitude)
            ? _userLatLng!.latitude
            : _garageLatLng.latitude,
        (_userLatLng!.longitude > _garageLatLng.longitude)
            ? _userLatLng!.longitude
            : _garageLatLng.longitude,
      ),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  void _startPolylineAnimation() {
    int index = 0;
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (index >= _fullRoute.length) {
        timer.cancel();
        return;
      }
      setState(() {
        _animatedRoute.add(_fullRoute[index]);
        _animatedPolyline = Polyline(
          polylineId: const PolylineId("animatedRoute"),
          points: _animatedRoute,
          width: 6,
          color: Colors.blue,
        );
      });
      index++;
    });
  }

  Future<List<LatLng>> _getRoutePoints(
      LatLng origin, LatLng destination) async {
    const apiKey = "Your_api_key_here"; // Replace with your Google Maps API key

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json"
      "?origin=${origin.latitude},${origin.longitude}"
      "&destination=${destination.latitude},${destination.longitude}"
      "&key=$apiKey",
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    if (data['status'] == 'OK') {
      final points = data['routes'][0]['overview_polyline']['points'];
      final legs = data['routes'][0]['legs'][0];
      _distance = legs['distance']['text'];
      _eta = legs['duration']['text'];
      return _decodePolyline(points);
    }
    return [];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return polyline;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF003579) : const Color(0xFF8D1113),
        title: Text('Navigate to Garage',
            style: GoogleFonts.saira(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          _userLatLng == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (controller) =>
                      _controller.complete(controller),
                  initialCameraPosition: CameraPosition(
                    target: _userLatLng!,
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines:
                      _animatedPolyline != null ? {_animatedPolyline!} : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
          if (_eta != null && _distance != null)
            Positioned(
              top: 20,
              left: 15,
              right: 15,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black87 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("ETA: $_eta", style: GoogleFonts.saira(fontSize: 14)),
                    Text("Distance: $_distance",
                        style: GoogleFonts.saira(fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final url = Uri.parse(
              'https://www.google.com/maps/dir/?api=1&destination=${_garageLatLng.latitude},${_garageLatLng.longitude}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open Google Maps')),
            );
          }
        },
        backgroundColor: const Color(0xFF003579),
        icon: const Icon(Icons.navigation),
        label: const Text("Open in Google Maps"),
      ),
    );
  }
}
