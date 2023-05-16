import 'package:flutter/material.dart';
import 'loginPage.dart';
import '../component/loginButton.dart';
import '../constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:parking_app/screen_model/coffee_provider.dart';
import 'package:parking_app/model/coffee.dart';
import "parking.dart";

import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  final ValueNotifier<List<Parking>> parkings;
  const RankingPage({Key? key, required this.parkings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    parkings.value.sort((a, b) => a.name.compareTo(b.name));
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Ranking'),
      ),
      body: ListView.builder(
        itemCount: parkings.value.length,
        itemBuilder: (context, index) {
          final parking = parkings.value[index];
          return ListTile(
            title: Text(parking.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${parking.latLng.latitude}, ${parking.latLng.longitude}'),
                  Text('Congestion: ${parking.congestion}'),
                ]),
            onTap: () {
              Navigator.of(context).pushNamed("/navi", arguments: parking);
            },
          );
        },
      ),
    );
  }
}
