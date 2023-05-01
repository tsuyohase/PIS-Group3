import 'package:flutter/material.dart';

class Navitime {
  String navitimeId;
  String name;
  int distance;
  int capacity;

  Navitime({this.navitimeId = '', required this.name, required this.distance, required this.capacity});

  factory Navitime.fromJson(Map<String, dynamic> json) {
    return Navitime(name: json["name"], distance: json['distance'],capacity: json["details"][0]["parking"]["capacity"]);
  }

  Map<String, Object?> toJson() {
    return {'name': name, 'distance': distance};
  }
}
