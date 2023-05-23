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
import 'package:crypto/crypto.dart';

import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import '../model/ml.dart';

class GoogleMapWidget extends StatelessWidget {
  const GoogleMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _GoogleMapWidget(),
    );
  }
}

///初心者マークの描画
class _LeftDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width * 1.0, size.height * 0.3)
      ..lineTo(size.width * 1.0, size.height * 1.0)
      ..lineTo(0, size.height * 0.7)
      ..close();
  }
  @override
  bool shouldReclip(CustomClipper oldclipper) {
    return true;
  }
}
class _RightDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip (Size size) {
    return Path()
      ..lineTo(0, size.height * 0.3)
      ..lineTo(size.width * 1.0, 0)
      ..lineTo(size.width * 1.0, size.height * 0.7)
      ..lineTo(0, size.height * 1.0)
      ..close();
  }
  @override
  bool shouldReclip(CustomClipper oldclipper) {
    return true;
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

  late FirebaseCustomModel cm;

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
      cursorColor: Colors.black, //カーソルの色
      style: const TextStyle(
        //テキストのスタイル
        color: Colors.black,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search, //キーボードのアクションボタンを指定
      decoration: const InputDecoration(
        //TextFiledのスタイル
        enabledBorder: UnderlineInputBorder(
            //デフォルトのTextFieldの枠線
            borderSide: BorderSide(color: Colors.black)),
        focusedBorder: UnderlineInputBorder(
            //TextFieldにフォーカス時の枠線
            borderSide: BorderSide(color: Colors.black)),
        hintText: 'Search', //何も入力してないときに表示されるテキスト
        hintStyle: TextStyle(
          //hintTextのスタイル
          color: Color.fromARGB(255, 215, 213, 213),
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
          LatLng(position.value.latitude, position.value.longitude), 14),
    );
  }

  // 現在値を取得して駐車場のリストを追加する
  Future<void> _getParking(
      LatLng position,
      ValueNotifier<Map<String, Marker>> markers,
      ValueNotifier<List<Parking>> parkings) async {
    final keyword = "parking";
    final radius = "1500";
// ここでもAPIキーを使用する。
    String requestUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude}%2C${position.longitude}&radius=${radius}&language=ja&query=${keyword}&type=parking&key=${dotenv.get("GOOGLE_MAP_API_KEY")}';
    http.Response? response;
    response = await http.get(Uri.parse(requestUrl));
    final mapController = await _mapController.future;

    if (response.statusCode == 200) {
      parkings.value = [];
      final res = jsonDecode(response.body);
      var results_list = res["results"];
      for (int i = 0; i < results_list.length; i++) {
        var latitude = results_list[i]["geometry"]["location"]['lat'];
        var longitude = results_list[i]["geometry"]["location"]['lng'];
        parkings.value.add(Parking(
            latLng: LatLng(latitude, longitude),
            name: results_list[i]["name"]));
      }
    }
  }

  //Parkingを受け取りcongestionに値を追加
  Future<void> _getCongestion(Parking parking) async {
    await dotenv.load(fileName: '.env');
    final String origin =
        "${parking.latLng.latitude},${parking.latLng.longitude}";
    //駐車場の位置から少し離れた場所を目的地に設定
    final String destination =
        "${parking.latLng.latitude + 0.001},${parking.latLng.longitude + 0.001}";
    //リクエストパラメータの設定
    final Map<String, String> params = {
      "origin": origin,
      "destination": destination,
      "departure_time": "now",
      "key": dotenv.get("GOOGLE_MAP_API_KEY"),
    };
    //目的地までの移動時間を調べる
    final Uri uri =
        Uri.https("maps.googleapis.com", "/maps/api/directions/json", params);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //混雑度を考慮した移動時間
      final durationInTraffic =
          data['routes'][0]['legs'][0]['duration_in_traffic']['value'];
      //混雑度を考慮しない移動時間
      final duration = data['routes'][0]['legs'][0]['duration']['value'];
      //移動時間の比をcongestionとしてparkingに追加
      final congestion = durationInTraffic / duration;
      parking.congestion = congestion;
    } else {
      throw Exception("Failed to get data from API.");
    }
  }

  //parkingsを受け取り
  Future<void> _getNearWidth(Parking parking) async {
    //変数定義
    const String REQUEST_CODE = "i3uWChjt4PVAiv7VAyAS";
    const CID = "p2300410";
    const NAVITIME_HOST = "trial.api-service.navitime.biz";
    const QUERY = "v1/shape_car";
    //環境変数の読み込み
    await dotenv.load(fileName: '.env');
    final signature_key = utf8.encode(dotenv.get('NAVITIME_API_KEY'));
    //署名の発行
    String signature = Hmac(sha256, signature_key)
        .convert(utf8.encode(REQUEST_CODE))
        .toString();
    //  final Uri uri = Uri.https("maps.googleapis.com", "/maps/api/directions/json", params);
    //final response = await http.get(uri);
    final String origin =
        "${parking.latLng.latitude},${parking.latLng.longitude}";
    //駐車場の位置から少し離れた場所を目的地に設定
    final String destination =
        "${parking.latLng.latitude + 0.001},${parking.latLng.longitude + 0.001}";
    final dio = Dio();
    //String url = "https://$NAVITIME_HOST/$CID/$QUERY";
    final url =
        'https://$NAVITIME_HOST/$CID/$QUERY?start=$origin&goal=$destination&request_code=$REQUEST_CODE&signature=$signature';

    //final response = await http.get(uri);
    /*
        Map<String, String> params = {
          "start": origin,
          "goal": destination,
          "request_code": dotenv.get("NAVITIME_API_KEY"),
          "signature": signature
        };
        final Uri uri = Uri.https(NAVITIME_HOST,"/$CID/$QUERY",params);*/
    try {
      final response = await dio.get(url);
      //final response = await http.get(Uri.parse(url), headers: params);
      if (response.statusCode == 200) {
        final features = response.data["features"] as List<dynamic>;
        //List features = jsonDecode(response.data)["features"];
        if (features.isNotEmpty) {
          List nearWidthList = [];
          String nearWidth = "";
          for (var feature in features) {
            if (feature["properties"].containsKey("road_width_grade")) {
              nearWidth = (feature["properties"]["road_width_grade"]);
              break;
            }
          }
          int width = 0;
          if (nearWidth == 'broad') {
            width = 2;
          } else if (nearWidth == 'narrow') {
            width = 1;
          }
          parking.nearWidth = width;
        }
      } else {
        throw Exception("Failed to load data from server.");
      }
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  void _getParkingsInfo(ValueNotifier<List<Parking>> parkings) async {
    List<Future<void>> futureList = [];
    for (Parking parking in parkings.value) {
      futureList.add(_getCongestion(parking));
      futureList.add(_getNearWidth(parking));
    }
    await Future.wait(futureList);
  }

  //Parkingを受け取りcongestionに値を追加
  Future<void> _getMLResult(Parking parking) async {
    List<double> parkingData = [
      parking.capacity.toDouble(),
      parking.occupancy.toDouble(),
      parking.congestion,
      parking.nearWidth.toDouble()
    ];
    List<double> input = MachineLearning.standardScaler(parkingData);
    List<List<dynamic>> output =
        await MachineLearning.runProcessResult(cm, input)
            as List<List<dynamic>>;
    parking.difficulty = output[0][1];
  }

  void _getDifficulty(ValueNotifier<List<Parking>> parkings) async {
    cm = await MachineLearning.getModel();

    List<Future<void>> futureList = [];
    for (Parking parking in parkings.value) {
      futureList.add(_getMLResult(parking));
    }

    await Future.wait(futureList);

    parkings.value.sort((a, b) => b.difficulty.compareTo(a.difficulty));
    for (int i = 0; i < parkings.value.length; i++) {
      parkings.value[i].rank = i;
    }
  }

  //parkings中の駐車場座標にマーカーを表示
  Future<void> _setParkingLocation(
      BuildContext context,
      ValueNotifier<Map<String, Marker>> markers,
      ValueNotifier<List<Parking>> parkings) async {
    final List<Parking> parkingList = parkings.value;
    final Map<String, Marker> markerMap = {};

    for (int i = 0; i < parkingList.length; i++) {
      final Parking parking = parkingList[i];
      BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
      if (i == 0) {
        icon =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      } else if (i == 1) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      } else if (i == 2) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      }
      final Marker marker = Marker(
          markerId: MarkerId('parking${i + 1}'),
          position: parking.latLng,
          onTap: () {
            // showParking.value = parking;
            // showDetail.value = true;
            _showParkingDetail(context, parking);
          },
          icon: icon,
          //markerをタップすると駐車場名が表示
          infoWindow: InfoWindow(title: parking.name));
      markerMap['parking${i + 1}'] = marker;
    }
    //元々保持していたマーカーは削除
    markers.value.clear();
    markers.value = markerMap;
  }

  void _showParkingDetail(BuildContext context, Parking parking) {
    showDialog(
      barrierColor: Colors.black.withOpacity(0),
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.topCenter,
          title: Text(parking.name),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            // SimpleDialogOption(
            //   child: Text("latitude : " + parking.latLng.latitude.toString()),
            // ),
            // SimpleDialogOption(
            //   child: Text("longitude : " + parking.latLng.longitude.toString()),
            // ),
            SimpleDialogOption(
              child: Text("駐車難易度 : " + parking.difficulty.toString()),
            ),
            SimpleDialogOption(
              child: Text("ランキング: " + parking.rank.toString()),
            ),
            ElevatedButton(
              child: const Text("ここに決定"),
              onPressed: () {
                Navigator.of(context).pushNamed("/navi", arguments: parking);
              },
            ),
          ]),
        );
      },
    );
  }

  Future<LatLng> getCenter() async {
    final controller = await _mapController.future;
    LatLngBounds visibleRegion = await controller.getVisibleRegion();
    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) /
          2,
    );

    return centerLatLng;
  }

  // Widget _parkingDetail(
  //     BuildContext context, ValueNotifier<Parking> showParking) {
  //   return SimpleDialog(
  //     alignment: Alignment.topCenter,
  //     title: Text(showParking.value.name),
  //     children: <Widget>[
  //       SimpleDialogOption(
  //         child: Text(
  //             "latitude : " + showParking.value.latLng.latitude.toString()),
  //       ),
  //       SimpleDialogOption(
  //         child: Text(
  //             "longitude : " + showParking.value.latLng.longitude.toString()),
  //       ),
  //       SimpleDialogOption(
  //         child: Text("駐車難易度 : " + showParking.value.difficulty.toString()),
  //       ),
  //       SimpleDialogOption(
  //         child: Text("ランキング: " + showParking.value.rank.toString()),
  //       ),
  //       ElevatedButton(
  //         child: const Text("ここに決定"),
  //         onPressed: () {
  //           Navigator.of(context)
  //               .pushNamed("/navi", arguments: showParking.value);
  //         },
  //       ),
  //       FloatingActionButton(onPressed: () {
  //         Navigator.of(context).pop();
  //       })
  //     ],
  //   );
  // }

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
    final searching = useState<bool>(false);
    // final showDetail = useState<bool>(false);
    // final showParking =
    //     useState<Parking>(Parking(latLng: LatLng(0, 0), name: "initial"));

    // 一度だけ実行(うまく動いていない)
    useEffect(() {
      _setCurrentLocation(position, markers);
      return;
    }, const []);

    _animateCamera(position);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 215, 213, 213),
        leadingWidth: 80,
        leading: Row (
         children: [
        IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/ranking", arguments: parkings);
              // ランキング表示
            },
            icon: Icon(Icons.assignment, color: Colors.black)),
        InkWell(
            onTap: (){}, //ここにボタンを押した時の指示を記述
            child: Container(
              height: 25,
            child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
              ClipPath(
                clipper: _LeftDiagonalClipper(),
                child: Container(
                decoration: BoxDecoration(
                 color: Colors.yellow),
                width: 10,)
              ),
              ClipPath(
                clipper: _RightDiagonalClipper(),
                child: Container(
                decoration: BoxDecoration(
                 color: Colors.green),
                width: 10,)
                )
            ]
          )
          ),
        ),
        ],
        ),
        title: !isSearch.value
            ? Center(
                child: IconButton(
                    onPressed: () {
                      isSearch.value = true;
                      predictions.value = [];
                    },
                    icon: Icon(Icons.search, color: Colors.black)),
              )
            : _searchTextField(hasPositon, predictions),
        actions: !isSearch.value
            ? [
                userID == ''
                    ? IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/login");
                        },
                        icon: Icon(Icons.login, color: Colors.black))
                    : IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/mypage");
                        },
                        icon: Icon(Icons.person, color: Colors.black))
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
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  child: Column(children: [
                    Text("Let's Search!",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    Text("at this point",
                        style: TextStyle(color: Colors.black)),

                    ///Text("経度 : " + position.value.longitude.toString(), style: TextStyle(color: Colors.black)),
                  ]),
                  onPressed: () async {
                    isSearch.value = false;
                    // positoin.value.latitudeで緯度取得
                    // postion.value.longitudeで軽度取得できる
                    searching.value = true;

                    LatLng cp = await getCenter();

                    position.value = cp;

                    await _getParking(cp, markers, parkings);
                    // await _getCongestion(parkings);
                    debugPrint(parkings.value[1].congestion.toString());
                    _getParkingsInfo(parkings);
                    debugPrint(parkings.value[1].congestion.toString());
                    _getDifficulty(parkings);

                    // 緯度経度をもとにnavitimeのapiを叩く処理をここに書く
                    // await _getNearWidth(parkings);

                    searching.value = false;

                    //駐車場取得メッセージの設定
                    var parkingMessage = "";

                    if (parkings.value.length > 0) {
                      parkingMessage = "Success！";
                      _setParkingLocation(context, markers, parkings);
                    } else {
                      parkingMessage = "駐車場はありません";
                    }
                    ;
                    //ダイアログの表示
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromARGB(255, 215, 213, 213),
                          title: Text(parkingMessage),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.yellow),
                              child: Text("OK",
                                  style: TextStyle(color: Colors.black)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
                    );
                  }),
            ),
          ),
          if (hasPositon.value)
            _searchListView(position, hasPositon, predictions, markers),
          if (searching.value)
            Center(
                child: CircularProgressIndicator(
              strokeWidth: 4,
            )),
          // if (showDetail.value) _parkingDetail(context, showParking),
        ],
      ),
    );
  }
}
