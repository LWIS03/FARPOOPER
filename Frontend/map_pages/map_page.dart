import 'dart:async';
import 'dart:convert';
import 'package:farpooper_frontend/Classes/getPoop.dart';
import 'package:farpooper_frontend/Classes/poop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng fallbackLocation = LatLng(51.221111111111, 4.3997222222222);
  int _userPoints = 0;
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
    _getPlayerPoints();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getPlayerPoints() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;
      final uri = Uri.parse("http://10.0.2.2:8080/Users/points/$uid");

      final resp = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (resp.statusCode == 200) {
        debugPrint("CACAS RECIBIDAS OK: ${resp.body}");
        final points = int.parse(resp.body);
        safeSetState(() => _userPoints = points);
      }

      else {
        debugPrint("NO POINTS: ${resp.body}");
        safeSetState(() => _userPoints = 0);
      }
    }
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

  Future<void> _getPoops() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;
      final uri = Uri.parse("http://10.0.2.2:8080/Poops/uid/$uid");

      final resp = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (resp.statusCode == 200) {
        debugPrint("POops recived: ${resp.body}");

        final List<dynamic> jsonList = jsonDecode(resp.body);
        final Set<GetPoop> poops =
        jsonList.map((json) => GetPoop.fromJson(json)).toSet();

        final Set<Marker> poopMarkers = {};
        final skin = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(64, 64)),
          'assets/markers/default.png',
        );
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
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(zoom: 17, target: newPos),
        ));
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
              scrollGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition != null
                    ? LatLng(_initialPosition!.latitude, _initialPosition!.longitude)
                    : fallbackLocation,
                zoom: 17,
              ),
            ),
            IgnorePointer(
              ignoring: true,
              child: SafeArea(
                  child: Align(
                    alignment:  Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, right: 12),
                      child: _ScoreChip(points: _userPoints),
                    ),
                  )
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'fabMyLocation',
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
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'fabAddPoop',
            backgroundColor: Colors.redAccent,
            onPressed: () {
              dialogAddPoop(context);
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Future<void> dialogAddPoop(BuildContext context) {
    var poopNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ADDING A POOP'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: poopNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name your Poop!',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "⚠️ Please enter a name for your poop!";
                }
                return null;
              },
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('NOPE :('),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    final position = await Geolocator.getCurrentPosition();
                    final coordNewPoop =
                    LatLng(position.latitude, position.longitude);

                    Poop newPoop = Poop(
                      uid: currentUser.uid,
                      name: poopNameController.text.trim(),
                      skinId: 1,
                      coordinates: coordNewPoop,
                    );

                    final uri = Uri.parse("http://10.0.2.2:8080/Poops/add");
                    final resp = await http.put(
                      uri,
                      headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                      },
                      body: jsonEncode(newPoop.toJson()),
                    );

                    if (resp.statusCode != 200) {
                      debugPrint("Error ${resp.statusCode}: ${resp.body}");
                    } else {
                      _getPoops();
                      _getPlayerPoints();
                    }
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('OK!'),
            ),
          ],
        );
      },
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

class _ScoreChip extends StatelessWidget {
  final int points;
  const _ScoreChip({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(blurRadius: 10, spreadRadius: 0, offset: Offset(0, 4), color: Colors.black12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 18),
          const SizedBox(width: 6),
          Text(
            '$points pts',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

