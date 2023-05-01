import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

Set<Marker> _createMarker(LatLng _center, String _markerId, _icon) {
  return {
    Marker(markerId: MarkerId(_markerId), position: _center, icon: _icon),
  };
}
