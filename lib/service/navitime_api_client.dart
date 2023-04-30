import 'package:parking_app/model/navitime.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class NavitimeApiClient {
  //request_codeはこちら側が自由に指定するコード。本来は毎回変えたほうがいい。
  final String REQUEST_CODE = "i3uWChjt4PVAiv7VAyAS";
  final CID = "p2300410";
  final HOST = "trial.api-service.navitime.biz";
  Future<List<Navitime>?> fetchList() async {
    //環境変数の読み込み
    await dotenv.load(fileName: '.env');
    //HMAC-SHA256 アルゴリズムで署名の作成
    final signature_key = utf8.encode(dotenv.get('NAVITIME_API_KEY'));
    String signature = Hmac(sha256, signature_key).convert(utf8.encode(REQUEST_CODE)).toString();
    final dio = Dio();
    //APIへのアクセス
    final url = 'https://$HOST/$CID/v1/parking?coord=35.68126232447219,139.76712479827628&options=detail&request_code=$REQUEST_CODE&signature=$signature';
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      try {
        final datas = response.data["items"] as List<dynamic>;
        final list = datas.map((e) => Navitime.fromJson(e)).toList();
        return list;
      } catch (e) {
        throw e;
      }
    }
  }
}
