import 'dart:async';
import 'dart:convert';
import 'package:farpooper_frontend/Classes/getPoop.dart';
import 'package:farpooper_frontend/MainPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GlobalMap extends StatefulWidget {
  const GlobalMap({super.key});

  @override
  State<GlobalMap> createState() => _MapPageState();
}

class _MapPageState extends State<GlobalMap> {
  static const LatLng fallbackLocation = LatLng(51.221111111111, 4.3997222222222);

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Position? _initialPosition;
  Timer? _locationUpdateTimer;

  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _getPoops();
    _setInitialLocation();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _upsertMyLocationMarker(LatLng pos) async {
    const meId = MarkerId('me');

    final skin = await BitmapDescriptor.asset(
      const ImageConfiguration(
          size: Size(64, 64)),
      'assets/markers/ActualLocation.png',);

    safeSetState(() {
      _markers.removeWhere((m) => m.markerId == meId);
      _markers.add(
        Marker(markerId: meId, icon: skin).copyWith(positionParam: pos),
      );
    });
  }

  Future<void> _getPoops() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;
      final uri = Uri.parse("http://10.0.2.2:8080/Poops/uid/$uid"); 
      final resp = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        debugPrint("CACAS RECIBIDAS OK: ${resp.body}");

        final List<dynamic> jsonList = jsonDecode(resp.body);
        final Set<GetPoop> poops =
        jsonList.map((json) => GetPoop.fromJson(json)).toSet();

        final Set<Marker> poopMarkers = {};
        final skin = await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(64, 64)),
            'assets/markers/default.png',);
        for (final poop in poops) {
          final pos = LatLng(poop.coordenates.first, poop.coordenates.second);
          poopMarkers.add(
            Marker(
              markerId: MarkerId('poop-${poop.id}'),
              icon: skin,
              position: pos,
              infoWindow: InfoWindow(
                title: poop.name,
                snippet: 'Pts: ${poop.points}',
              ),
            ),
          );
        }

        safeSetState(() {
          _markers.addAll(poopMarkers);
        });
      } else {
        debugPrint("Error ${resp.statusCode}: ${resp.body}");
      }
    }
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;
      try {
        final position = await currentPosition();
        if (!mounted) return;

        final newPos = LatLng(position.latitude, position.longitude);

        _upsertMyLocationMarker(newPos);

        //_mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
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
        CameraPosition(zoom: 5, target: pos),
      ),);
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
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition != null
                    ? LatLng(_initialPosition!.latitude, _initialPosition!.longitude)
                    : fallbackLocation,
                zoom: 14,
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 10),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MyApp()));
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                )
              ),
            ),
          ]
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
                CameraPosition(zoom: 17, target: pos),
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
