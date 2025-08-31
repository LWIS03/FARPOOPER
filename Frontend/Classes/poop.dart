import 'package:google_maps_flutter/google_maps_flutter.dart';

class Poop{
  final String uid;
  final int skinId;
  final String name;
  final LatLng coordinates;

  Poop({ required this.uid,
    required this.skinId,
    required this.name,
    required this.coordinates});

  Map<String, dynamic> toJson()=>{
    'uid': uid,
    'skinId': skinId,
    'name': name,
    'coordinates':  {
      "first": coordinates.latitude,
      "second": coordinates.longitude,
    },
  };


}