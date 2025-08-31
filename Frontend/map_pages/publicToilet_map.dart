import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:farpooper_frontend/MainPage.dart';

class ToiletMap extends StatefulWidget {
  const ToiletMap({super.key});

  @override
  State<ToiletMap> createState() => _MapPageState();
}

class _MapPageState extends State<ToiletMap> {
  static const LatLng fallbackLocation = LatLng(51.221111111111, 4.3997222222222);

  final toiletIcon = BitmapDescriptor.asset(
  const ImageConfiguration(size: Size(64, 64)),
  'assets/markers/toitoi.png',
  );
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Position? _initialPosition;
  Timer? _locationUpdateTimer;

  // debounce para Overpass
  Timer? _fetchDebounce;
  // cache simple por bbox string para evitar repetidos inmediatos
  String? _lastFetchedBboxKey;

  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _fetchDebounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _upsertMyLocationMarker(LatLng pos) async {
    const meId = MarkerId('me');

    final skin = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(64, 64)),
      'assets/markers/ActualLocation.png',
    );

    safeSetState(() {
      _markers.removeWhere((m) => m.markerId == meId);
      _markers.add(
        Marker(markerId: meId, icon: skin).copyWith(positionParam: pos),
      );
    });
  }

  // ========== NUEVO: FETCH DE BAÑOS (Overpass) ==========
  Future<void> _fetchToiletsInBbox(LatLngBounds bbox) async {
    // Clave para cache simple
    final key =
        '${bbox.southwest.latitude.toStringAsFixed(5)},${bbox.southwest.longitude.toStringAsFixed(5)},'
        '${bbox.northeast.latitude.toStringAsFixed(5)},${bbox.northeast.longitude.toStringAsFixed(5)}';
    if (_lastFetchedBboxKey == key) return; // misma bbox reciente

    _lastFetchedBboxKey = key;

    final south = bbox.southwest.latitude;
    final west = bbox.southwest.longitude;
    final north = bbox.northeast.latitude;
    final east = bbox.northeast.longitude;

    const endpoint = 'https://overpass-api.de/api/interpreter';
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="toilets"]($south,$west,$north,$east);
  way["amenity"="toilets"]($south,$west,$north,$east);
  relation["amenity"="toilets"]($south,$west,$north,$east);
);
out center tags;
''';

    try {
      final resp = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: 'data=${Uri.encodeQueryComponent(query)}',
      );

      if (resp.statusCode != 200) {
        debugPrint('ERROR OVERPASS ${resp.statusCode}: ${resp.body}');
        return;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final List elements = (data['elements'] as List?) ?? [];

      // Icono para baños


      // Construimos markers
      final Set<Marker> toiletMarkers = {};
      for (final e in elements) {
        final m = e as Map<String, dynamic>;
        final id = m['id'].toString();
        final tags = (m['tags'] as Map?)?.cast<String, dynamic>() ?? {};
        final name = tags['name'] as String?;
        final fee = (tags['toilets:fee'] ?? tags['fee'])?.toString();
        final wheel = (tags['toilets:wheelchair'] ?? tags['wheelchair'])?.toString();
        final unisex = tags['toilets:unisex']?.toString();

        // lat/lon pueden venir directo (node) o en center (way/relation)
        final lat = (m['lat'] ?? m['center']?['lat'])?.toDouble();
        final lon = (m['lon'] ?? m['center']?['lon'])?.toDouble();
        if (lat == null || lon == null) continue;

        final info = <String>[];
        if (fee != null) info.add(fee.toLowerCase() == 'yes' ? 'Paid' : (fee.toLowerCase() == 'no' ? 'Free' : ''));
        if (wheel != null) info.add(wheel.toLowerCase() == 'yes' ? '♿' : '');
        if (unisex != null && (unisex.toLowerCase() == 'yes' || unisex.toLowerCase() == 'no')) {
          info.add(unisex.toLowerCase() == 'yes' ? 'Unisex' : 'No unisex');
        }
        final snippet = info.where((s) => s.isNotEmpty).join(' · ');

        toiletMarkers.add(
          Marker(
            markerId: MarkerId('toilet-$id'),
            icon: await toiletIcon,
            position: LatLng(lat, lon),
            infoWindow: InfoWindow(
              title: name ?? 'Public Toilet',
              snippet: snippet.isEmpty ? null : snippet,
            ),
          ),
        );
      }

      safeSetState(() {
        _markers.removeWhere((m) => m.markerId.value.startsWith('toilet-'));
        _markers.addAll(toiletMarkers);
      });
      debugPrint('BAÑOS RECIBIDOS: ${toiletMarkers.length}');
    } catch (e) {
      debugPrint('Excepción Overpass: $e');
    }
  }

  // Debounce disparado al parar la cámara
  void _scheduleFetchToilets() {
    _fetchDebounce?.cancel();
    _fetchDebounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final controller = _mapController;
        if (controller == null) return;
        final bounds = await controller.getVisibleRegion();
        // Evita bbox inválidos (cuando el mapa aún no está listo)
        if (bounds.northeast.latitude == 0 && bounds.northeast.longitude == 0) return;
        _fetchToiletsInBbox(bounds);
      } catch (e) {
        debugPrint('No pude obtener bounds: $e');
      }
    });
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;
      try {
        final position = await currentPosition();
        if (!mounted) return;
        final newPos = LatLng(position.latitude, position.longitude);
        _upsertMyLocationMarker(newPos);
        // _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
      } catch (e) {
        debugPrint("Auto-update error: $e");
      }
    });
  }

  Future<void> _setInitialLocation() async {
    try {
      final position = await currentPosition();
      if (!mounted) return;

      final pos = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        const CameraPosition(zoom: 15, target: fallbackLocation),
      ));
      _initialPosition = position;
      _upsertMyLocationMarker(pos);
    } catch (e) {
      debugPrint("Error getting initial location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            GoogleMap(
              zoomGesturesEnabled: false,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              markers: _markers,
              onMapCreated: (controller) async {
                _mapController = controller;
                try {
                  final p = await currentPosition();
                  final pos = LatLng(p.latitude, p.longitude);
                  controller.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(zoom: 15, target: pos),
                  ));
                } catch (_) {}
                _scheduleFetchToilets();
              },
              onCameraIdle: _scheduleFetchToilets,
              initialCameraPosition: CameraPosition(
                target: _initialPosition != null
                    ? LatLng(_initialPosition!.latitude, _initialPosition!.longitude)
                    : fallbackLocation,
                zoom: 15,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          try {
            final position = await currentPosition();
            if (!mounted) return;

            final pos = LatLng(position.latitude, position.longitude);

            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(zoom: 14, target: pos),
              ),
            );

            _upsertMyLocationMarker(pos);
          } catch (e) {
            debugPrint("Error getting location on button press: $e");
          }
        },
        child: const Icon(Icons.my_location, size: 30),
      ),
    );
  }

  Future<Position> currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied.");
    }

    return Geolocator.getCurrentPosition();
  }
}
