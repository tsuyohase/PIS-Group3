import 'package:parking_app/service/coffee_api_client.dart';

class CoffeeRepository {
  final api = CoffeeApiClient();
  dynamic fetchList() async {
    return await api.fetchList();
  }
}
