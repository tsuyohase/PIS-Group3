import 'package:parking_app/service/navitime_api_client.dart';

class NavitimeRepository {
  final api = NavitimeApiClient();
  dynamic fetchList() async {
    return await api.fetchList();
  }
}
