import 'dart:convert';

import 'package:farpooper_frontend/Classes/user.dart';
import 'package:farpooper_frontend/MainPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;



class ChooseHome extends StatefulWidget {
  const ChooseHome({super.key});

  @override
  State<ChooseHome> createState() => _ChooseHomeState();
}

class _ChooseHomeState extends State<ChooseHome> {
  final TextEditingController placeController = TextEditingController();
  GoogleMapController? _mapController;

  static const LatLng _initialPos = LatLng(51.221111111111, 4.3997222222222);
  LatLng _selectedPos = _initialPos;
  final Set<Marker> _markers = {
    const Marker(markerId: MarkerId('init'), position: _initialPos),
  };

  @override
  void dispose() {
    placeController.dispose();
    super.dispose();
  }

  void _moveCamera(LatLng pos) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: pos, zoom: 16),
      ),
    );
  }

  void _updatePositionFromPrediction(Prediction p) {
    if (p.lat != null && p.lng != null) {
      final lat = double.tryParse(p.lat!.toString());
      final lng = double.tryParse(p.lng!.toString());
      if (lat != null && lng != null) {
        final pos = LatLng(lat, lng);
        setState(() {
          _selectedPos = pos;
          _markers
            ..clear()
            ..add(Marker(
              markerId: const MarkerId('place'),
              position: pos,
              infoWindow: InfoWindow(title: p.description ?? 'Ubicación'),
            ));
        });
        _moveCamera(pos);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Choose your home address")),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.white,
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: placeController,
                      googleAPIKey: ...,
                      inputDecoration: const InputDecoration(
                        labelText: "Address",
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                      ),
                      debounceTime: 700,
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction p) {
                        _updatePositionFromPrediction(p);
                      },
                      itemClick: (Prediction p) {
                        placeController.text = p.description ?? '';
                        placeController.selection = TextSelection.fromPosition(
                          TextPosition(offset: placeController.text.length),
                        );
                        _updatePositionFromPrediction(p);
                      },
                      itemBuilder: (context, index, Prediction p) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on),
                              const SizedBox(width: 7),
                              Expanded(child: Text(p.description ?? "")),
                            ],
                          ),
                        );
                      },
                      seperatedBuilder: const Divider(height: 1),
                      isCrossBtnShown: true,
                      containerHorizontalPadding: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      zoomGesturesEnabled: false,
                      initialCameraPosition: const CameraPosition(
                        target: _initialPos,
                        zoom: 14,
                      ),
                      onMapCreated: (c) => _mapController = c,
                      markers: _markers,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                    ),
                  ),
                ),
               ElevatedButton(onPressed: () async {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if(currentUser != null){

                    AppUser NewUser = AppUser(
                        uid: currentUser.uid,
                        email: currentUser.email ?? "",
                        username: currentUser.displayName ?? "NoName",
                        homeCords: _selectedPos,
                    );


                    final uri = Uri.parse("http://10.0.2.2:8080/Users/new"); 
                    final resp = await http.put(
                      uri,
                      headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                      },
                      body: jsonEncode(NewUser.toJson()),
                    );

                    if (resp.statusCode == 200) {
                      print("Usuario enviado OK: ${resp.body}");
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MyApp()));
                    } else {
                      print("Error ${resp.statusCode}: ${resp.body}");
                    }
                  }
               },
                   child: Text('NEXT!',
                            style: TextStyle(fontSize: 18, color: Colors.black),),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
