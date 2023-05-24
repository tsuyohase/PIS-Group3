import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class Parking {
  LatLng latLng;
  String name;
  Parking({required this.latLng, required this.name});
  double congestion = 0;
  double difficulty = 0;
  int capacity = Random().nextInt(30); // あとでちゃんとデータをセットしないとだめ
  int nearWidth = 0;
  int occupancy = Random().nextInt(2);
  int rank = 0;
  int defaultRank = 0;
}
