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

class GoogleMapWidget extends StatelessWidget {
  const GoogleMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _GoogleMapWidget(),
    );
  }
}

class _GoogleMapWidget extends HookWidget {
  GooglePlace googlePlace = GooglePlace(dotenv.get("GOOGLE_MAP_API_KEY"));
  // 初期表示位置を渋谷駅に設定
  final Position _initialPosition = Position(
    latitude: 35.68126232447219,
    longitude: 139.76712479827628,
    timestamp: DateTime.now(),
    altitude: 0,
    accuracy: 0,
    heading: 0,
    floor: null,
    speed: 0,
    speedAccuracy: 0,
  );

  final Completer<GoogleMapController> _mapController = Completer();

  /// デバイスの現在位置を決定する。
  /// 位置情報サービスが有効でない場合、または許可されていない場合。
  /// エラーを返します
  Future<Position> _determinePosition() async {
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
    return await Geolocator.getCurrentPosition();
  }

  Widget _createMap(ValueNotifier<Map<String, Marker>> markers) {
    return GoogleMap(
      mapType: MapType.normal,
      onMapCreated: _mapController.complete,
      // 端末の位置情報を使用する。
      myLocationEnabled: true,
      // 端末の位置情報を地図の中心に表示するボタンを表示する。
      myLocationButtonEnabled: true,
      markers: markers.value.values.toSet(),
      initialCameraPosition: CameraPosition(
          target: LatLng(_initialPosition.latitude, _initialPosition.altitude),
          zoom: 15),
    );
  }

  //入力内容から結果取得
  void autoCompleteSearch(String value,
      ValueNotifier<List<AutocompletePrediction>> predictions) async {
    final result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      predictions.value = result.predictions!;
    }
  }

  // PlaceIDから画面表示する地点を取得する。
  Future<void> _getTargetLatLng(
      String? placeId, ValueNotifier<Map<String, Marker>> markers) async {
// ここでもAPIキーを使用する。
    String requestUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?language=ja&place_id=${placeId}&key=${dotenv.get("GOOGLE_MAP_API_KEY")}';
    http.Response? response;
    response = await http.get(Uri.parse(requestUrl));

    final mapController = await _mapController.future;

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      var latitude = res['result']['geometry']['location']['lat'];
      var longitude = res['result']['geometry']['location']['lng'];
      var address = res['result']['formatted_address'];
      mapController
          .animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));
      final marker = Marker(
        markerId: MarkerId(address),
        position: LatLng(latitude, longitude),
      );
      // markers.value.clear();
      markers.value[address] = marker;
    }
  }

  Widget _searchTextField(ValueNotifier<bool> hasPosition,
      ValueNotifier<List<AutocompletePrediction>> predictions) {
    //追加
    return TextField(
      onChanged: (value) {
        if (!hasPosition.value) {
          hasPosition.value = true;
        }
        if (value.isNotEmpty) {
          autoCompleteSearch(value, predictions); // 入力される毎に引数にその入力文字を渡し、関数を実行
        } else {
          if (predictions.value.isNotEmpty) {
            // ここで配列を初期化。初期化しないと文字が入力されるたびに検索結果が蓄積されてしまう。
            predictions.value = [];
          }
        }
      },
      autofocus: true, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
      cursorColor: Colors.white, //カーソルの色
      style: const TextStyle(
        //テキストのスタイル
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search, //キーボードのアクションボタンを指定
      decoration: const InputDecoration(
        //TextFiledのスタイル
        enabledBorder: UnderlineInputBorder(
            //デフォルトのTextFieldの枠線
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: UnderlineInputBorder(
            //TextFieldにフォーカス時の枠線
            borderSide: BorderSide(color: Colors.white)),
        hintText: 'Search', //何も入力してないときに表示されるテキスト
        hintStyle: TextStyle(
          //hintTextのスタイル
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _searchListView(
      ValueNotifier<bool> hasPosition,
      ValueNotifier<List<AutocompletePrediction>> predictions,
      ValueNotifier<Map<String, Marker>> markers) {
    //追加
    return ListView.builder(
      shrinkWrap: true,
      itemCount: predictions.value.length, // 検索結果を格納したpredictions配列の長さを指定
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(predictions.value[index].description
                .toString()), // 検索結果を表示。descriptionを指定すると場所名が表示されます。
            onTap: () async {
// 検索した住所を押した時の処理を記載
              _getTargetLatLng(predictions.value[index].placeId, markers);

              FocusScope.of(context).unfocus();

              hasPosition.value = false;
            },
          ),
        );
      },
    );
  }

  Future<void> _setCurrentLocation(ValueNotifier<Position> position,
      ValueNotifier<Map<String, Marker>> markers) async {
    final currentPosition = await _determinePosition();

    const decimalPoint = 3;
    // 過去の座標と最新の座標の小数点第三位で切り捨てた値を判定
    if ((position.value.latitude).toStringAsFixed(decimalPoint) !=
            (currentPosition.latitude).toStringAsFixed(decimalPoint) &&
        (position.value.longitude).toStringAsFixed(decimalPoint) !=
            (currentPosition.longitude).toStringAsFixed(decimalPoint)) {
      // 現在地座標にMarkerを立てる
      final marker = Marker(
        markerId: MarkerId(currentPosition.timestamp.toString()),
        position: LatLng(currentPosition.latitude, currentPosition.longitude),
      );
      markers.value.clear();
      markers.value[currentPosition.timestamp.toString()] = marker;
      // 現在地座標のstateを更新する
      position.value = currentPosition;
    }
  }

  Future<void> _animateCamera(ValueNotifier<Position> position) async {
    final mapController = await _mapController.future;

    await mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.value.latitude, position.value.longitude),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 初期表示座標のMarkerを設定
    final initialMarkers = {
      _initialPosition.timestamp.toString(): Marker(
        markerId: MarkerId(_initialPosition.timestamp.toString()),
        position: LatLng(_initialPosition.latitude, _initialPosition.longitude),
      ),
    };
    final position = useState<Position>(_initialPosition);
    final markers = useState<Map<String, Marker>>(initialMarkers);
    final predictions = useState<List<AutocompletePrediction>>([]);
    final hasPositon = useState<bool>(false);
    final isSearch = useState<bool>(false);

    _setCurrentLocation(position, markers);
    _animateCamera(position);

    return Scaffold(
      appBar: AppBar(
        title: !isSearch.value
            ? Text('Google Map Flutter Config')
            : _searchTextField(hasPositon, predictions),
        actions: !isSearch.value
            ? [
                IconButton(
                    onPressed: () {
                      isSearch.value = true;
                      predictions.value = [];
                    },
                    icon: Icon(Icons.search))
              ]
            : [
                IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      isSearch.value = false;
                    })
              ],
      ),
      body: Stack(
        children: [
          _createMap(markers),
          if (hasPositon.value)
            _searchListView(hasPositon, predictions, markers),
        ],
      ),
    );
  }
}
