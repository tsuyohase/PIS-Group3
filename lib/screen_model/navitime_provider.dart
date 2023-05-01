import 'package:parking_app/model/navitime.dart';
import 'package:parking_app/repository/navitime_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository(APIの取得)の状態を管理する
final navitimeRepositoryProvider = Provider((ref) => NavitimeRepository());

// 上記を非同期で管理する
final listProvider = FutureProvider<List<Navitime>>((ref) async {
  final repository = ref.read(navitimeRepositoryProvider);
  return await repository.fetchList();
});
