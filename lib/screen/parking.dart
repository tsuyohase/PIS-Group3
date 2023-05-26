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
  double distance = 0; //検索地点からの距離
  List<dynamic> photoURLList = [
    "https://www.10wallpaper.com/wallpaper/1366x768/2005/Mountains_Rocks_Lake_2020_Landscape_High_Quality_Photo_1366x768.jpg"
  ];
  //String photoURL = "https://www.10wallpaper.com/wallpaper/1366x768/2005/Mountains_Rocks_Lake_2020_Landscape_High_Quality_Photo_1366x768.jpg";
  //"https://media.istockphoto.com/vectors/prohibition-sign-no-photography-vector-id50731733[…]612x612&w=0&h=SmPmtJ_gcWPWH4RkFtlm6RKU1qnlQchSgSRSGdMrfFE=";
}
