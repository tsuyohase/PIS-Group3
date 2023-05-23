import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_hooks/flutter_hooks.dart';
import "parking.dart";
import 'loginPage.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' as Math;

class NaviPage extends StatefulWidget {
  final Parking parking;
  const NaviPage({super.key, required this.parking});

  @override
  State<NaviPage> createState() => _NaviPageState();
}

class _NaviPageState extends State<NaviPage> {
  GooglePlace googlePlace = GooglePlace(dotenv.get("GOOGLE_MAP_API_KEY"));
  // 初期表示位置を渋谷駅に設定
  final LatLng _initialPosition = LatLng(
    35.0364508,
    135.7816262,
  );

  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Polyline> _polyline = {};
  LatLng cp = LatLng(
    35.0364508,
    135.7816262,
  );

  /// デバイスの現在位置を決定する。
  /// 位置情報サービスが有効でない場合、または許可されていない場合。
  /// エラーを返します
  Future<LatLng> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 位置情報サービスが有効かどうかをテストします。
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 位置情報サービスが有効でない場合、続行できません。
      // 位置情報にアクセスし、ユーザーに対して
      // 位置情報サービスを有効にするようアプリに要請する。
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // ユーザーに位置情報を許可してもらうよう促す
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 拒否された場合エラーを返す
        return Future.error('Location permissions are denied');
      }
    }

    // 永久に拒否されている場合のエラーを返す
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // ここまでたどり着くと、位置情報に対しての権限が許可されているということなので
    // デバイスの位置情報を返す。
    final currentPosition = await Geolocator.getCurrentPosition();

    return LatLng(currentPosition.latitude, currentPosition.longitude);
  }

  @override
  void initState() {
    super.initState();
    _getRoutes();
  }

  Future<void> _getCurrentLocation() async {
    cp = await _determinePosition();
  }

  // ルート表示データ取得
  Future<void> _getRoutes() async {
    await _getCurrentLocation();
    List<LatLng> _points = await _createPolyline();
    setState(() {
      _polyline.add(Polyline(
          polylineId: const PolylineId("Route"),
          visible: true,
          color: Colors.blue,
          width: 5,
          points: _points));
    });
    await _animateCamera();
  }

  // マップの作成
  Widget _createMap() {
    return GoogleMap(
        mapType: MapType.normal,
        onMapCreated: _mapController.complete,
        // 端末の位置情報を使用する。
        myLocationEnabled: true,
        // 端末の位置情報を地図の中心に表示するボタンを表示する。
        myLocationButtonEnabled: true,
        initialCameraPosition: CameraPosition(
            target:
                LatLng(_initialPosition.latitude, _initialPosition.longitude),
            zoom: 15),
        polylines: _polyline,
        markers: {
          Marker(
              markerId: MarkerId("destination"),
              position: widget.parking.latLng,
              infoWindow: InfoWindow(title: widget.parking.name))
        });
  }

  // ルート表示
  Future<List<LatLng>> _createPolyline() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      dotenv.get("GOOGLE_MAP_API_KEY"),
      PointLatLng(cp.latitude, cp.longitude),
      PointLatLng(
          widget.parking.latLng.latitude, widget.parking.latLng.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    return polylineCoordinates;
  }

  Future<void> _animateCamera() async {
    final mapController = await _mapController.future;

    double east = Math.max(widget.parking.latLng.longitude, cp.longitude);
    double west = Math.min(widget.parking.latLng.longitude, cp.longitude);
    double south = Math.min(widget.parking.latLng.latitude, cp.latitude);
    double north = Math.max(widget.parking.latLng.latitude, cp.latitude);

    await mapController.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(southwest: LatLng(south,west), northeast: LatLng(north,east)),
        10));
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Color.fromARGB(255, 215, 213, 213),
        title: Container(
          alignment: Alignment.center,
          child: const Text('Navi Page', style: TextStyle(color: Colors.white)),
      )
      ),
          body: Stack(children: [
            _createMap(),
            Container(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                  child: Text("ここに決定！(Google mapとかに飛ばす？)"),
                  onPressed: () async {}),
            ),
          ]),
    );
  }
}
