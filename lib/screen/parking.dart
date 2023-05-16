import 'package:google_maps_flutter/google_maps_flutter.dart';
class Parking {
  LatLng latLng;
  String name;
  Parking({required this.latLng, required this.name});
  double congestion = 0;
  String nearWidth = "";
}