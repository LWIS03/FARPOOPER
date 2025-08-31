import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppUser{
  final String uid;
  final String email;
  final String username;
  final LatLng homeCords;

  AppUser({ required this.uid,
    required this.email,
    required this.username,
    required this.homeCords});

  Map<String, dynamic> toJson()=>{
    'username': username,
    'email': email,
    'uid': uid,
    'homeCords':  {
      "first": homeCords.latitude,
      "second": homeCords.longitude,
    },
  };


}