
import 'package:parking_app/model/coffee.dart';
import 'package:parking_app/repository/coffee_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository(APIの取得)の状態を管理する
final repositoryProvider = Provider((ref) => CoffeeRepository());

// 上記を非同期で管理する
final listProvider = FutureProvider<List<Coffee>>((ref) async {
  final repository = ref.read(repositoryProvider);
  return await repository.fetchList();
});
