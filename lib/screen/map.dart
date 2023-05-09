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
  final LatLng _initialPosition = LatLng(
    35.68126232447219,
    139.76712479827628,
  );

  final Completer<GoogleMapController> _mapController = Completer();

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
          target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
          zoom: 15),
    );
  }

  //入力内容から結果取得
  void autoCompleteSearch(String value,
      ValueNotifier<List<AutocompletePrediction>> predictions) async {
    final result = await googlePlace.autocomplete.get(value, language: 'ja');
    if (result != null && result.predictions != null) {
      predictions.value = result.predictions!;
    }
  }

  // PlaceIDから画面表示する地点を取得する。
  Future<void> _getTargetLatLng(ValueNotifier<LatLng> position, String? placeId,
      ValueNotifier<Map<String, Marker>> markers) async {
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
      position.value = LatLng(latitude, longitude);
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
      ValueNotifier<LatLng> position,
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
              _getTargetLatLng(
                  position, predictions.value[index].placeId, markers);

              FocusScope.of(context).unfocus();

              hasPosition.value = false;
            },
          ),
        );
      },
    );
  }

  Future<void> _setCurrentLocation(ValueNotifier<LatLng> position,
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
        markerId: MarkerId('current'),
        position: LatLng(currentPosition.latitude, currentPosition.longitude),
      );
      markers.value.clear();
      markers.value['current'] = marker;
      // 現在地座標のstateを更新する
      position.value = currentPosition;
    }
  }

  Future<void> _animateCamera(ValueNotifier<LatLng> position) async {
    final mapController = await _mapController.future;

    await mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
          LatLng(position.value.latitude, position.value.longitude), 15),
    );
  }

  // 現在値を取得して駐車場のリストを追加する
  Future<void> _getParking(ValueNotifier<LatLng> position,
      ValueNotifier<Map<String, Marker>> markers,ValueNotifier<List<Parking>> parkings) async {
    final keyword = "parking";
    final radius = "1500";
// ここでもAPIキーを使用する。
    String requestUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.value.latitude}%2C${position.value.longitude}&radius=${radius}&language=ja&query=${keyword}&type=parking&key=${dotenv.get("GOOGLE_MAP_API_KEY")}';
    http.Response? response;
    response = await http.get(Uri.parse(requestUrl));
    final mapController = await _mapController.future;

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      var results_list = res["results"];
      for (int i = 0; i < results_list.length; i++){
        var latitude = results_list[i]["geometry"]["location"]['lat'];
        var longitude = results_list[i]["geometry"]["location"]['lng'];
        parkings.value.add(Parking(latLng:LatLng(latitude, longitude), name: results_list[i]["name"]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 初期表示座標のMarkerを設定
    final initialMarkers = {
      'initial': Marker(
        markerId: MarkerId('initial'),
        position: _initialPosition,
      ),
    };
    final position = useState<LatLng>(_initialPosition);
    final markers = useState<Map<String, Marker>>(initialMarkers);
    final predictions = useState<List<AutocompletePrediction>>([]);
    final hasPositon = useState<bool>(false);
    final isSearch = useState<bool>(false);
    final parkings = useState<List<Parking>>([]);

    // 一度だけ実行(うまく動いていない)
    useEffect(() {
      _setCurrentLocation(position, markers);
      return;
    }, const []);

    _animateCamera(position);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              // ランキング表示
            },
            icon: Icon(Icons.assignment)),
        title: !isSearch.value
            ? Center(
                child: IconButton(
                    onPressed: () {
                      isSearch.value = true;
                      predictions.value = [];
                    },
                    icon: Icon(Icons.search)),
              )
            : _searchTextField(hasPositon, predictions),
        actions: !isSearch.value
            ? [
                userID == ''
                    ? IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/login");
                        },
                        icon: Icon(Icons.login))
                    : IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/mypage");
                        },
                        icon: Icon(Icons.person))
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
          Container(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
                child: Text("ここで駐車場検索！\n 緯度 : " +
                    position.value.latitude.toString() +
                    "\n 経度 : " +
                    position.value.longitude.toString()),
                onPressed: () {
                  isSearch.value = false;
                  // positoin.value.latitudeで緯度取得
                  // postion.value.longitudeで軽度取得できる
                  _getParking(position, markers,parkings);
                  // 緯度経度をもとにnavitimeのapiを叩く処理をここに書く
                }),
          ),
          if (hasPositon.value)
            _searchListView(position, hasPositon, predictions, markers),
          
        ],
      ),
    );
  }
}
