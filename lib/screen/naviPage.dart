import 'package:carousel_slider/carousel_slider.dart';
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
import '../model/ratingbar.dart';

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
    Future.delayed(const Duration(seconds: 1), () => _animateCamera());
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
    // 経路上の一番大きな関数を取得
    List<double> EWSN =
        await _locatePolyline(_polyline, east, west, south, north);
    east = EWSN[0];
    west = EWSN[1];
    south = EWSN[2];
    north = EWSN[3];
    LatLng southwest = LatLng(south, west);
    LatLng northeast = LatLng(north, east);
    await mapController.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(
                southwest: LatLng(south, west), northeast: LatLng(north, east)),
            50) //padding
        );
    // await mapController.animateCamera(CameraUpdate.zoomOut());
  }

  // polylineが存在する領域の端を返す関数
  Future<List<double>> _locatePolyline(Set<Polyline> polylines, double east,
      double west, double south, double north) async {
    for (Polyline polyline in polylines) {
      for (LatLng point in polyline.points) {
        east = Math.max(east, point.longitude);
        west = Math.min(west, point.longitude);
        south = Math.min(south, point.latitude);
        north = Math.max(north, point.latitude);
      }
    }
    // 4方位をリストで返す
    return [east, west, south, north];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title:
              Text('Parking Navigation', style: TextStyle(color: Colors.white)),
        ),
        body: Stack(children: [
          _createMap(),
          Container(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
                child: Text("案内終了"),
                onPressed: () async {
                  Navigator.of(context)
                      .pushNamed("/feedbackpage", arguments: widget.parking);
                }),
          ),
          //経路検索時の駐車場詳細ボタン
          Container(
            alignment: Alignment.topCenter,
            //余白を削除(写真が大きくなるがレイアウトが少し崩れる)
            //margin: EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              //ボタンを押すと詳細が表示
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentPadding: EdgeInsets.zero,
                      alignment: Alignment.topCenter,
                      content: SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                widget.parking.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            // SimpleDialogOption(
                            //   child: Text("latitude : " + parking.latLng.latitude.toString()),
                            // ),
                            // SimpleDialogOption(
                            //   child: Text("longitude : " + parking.latLng.longitude.toString()),
                            // ),
                            StaticRatingBar(
                              rating: widget.parking.difficulty *
                                  5, // 0から1までの数値を5倍した評価値を指定
                              size: 24.0, // 星のサイズを指定
                              color: Colors.yellow.shade700, // 星の色を指定
                              allowHalfRating: true, // 半分の星を許可する
                            ),

                            //駐車場の画像をスライドで表示.
                            CarouselSlider(
                                options: CarouselOptions(),
                                items: widget.parking.photoURLList.map((i) {
                                  return Image.network(i);
                                }).toList()),

                            SimpleDialogOption(
                              child: Text("ランキング: " +
                                  (widget.parking.rank + 1).toString()),
                            ),

                            //SimpleDialogOption(
                            //  child: Text("駐車難易度 : " + widget.parking.difficulty.toString()),
                            //),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 215, 213, 213),
              ),
              child: Text(
                widget.parking.name,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ]));
  }
}
