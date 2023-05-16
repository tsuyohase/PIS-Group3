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
        backgroundColor: Colors.green,
        title: Text('Parking Ranking', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.yellow,
      child: ListView.builder(
        itemCount: parkings.value.length,
        itemBuilder: (context, index) {
          final parking = parkings.value[index];
          return Column(
          children: [
            ListTile(
            title: Text(parking.name, style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${parking.latLng.latitude}, ${parking.latLng.longitude}', style: TextStyle(color: Colors.black)),
                  Text('Congestion: ${parking.congestion}', style: TextStyle(color: Colors.black)),
                  Text('Near Roads Width: ${parking.nearWidth}')
                ]),
            onTap: () {
              Navigator.of(context).pushNamed("/navi", arguments: parking);
            },
          ),
          Divider(
            height: 2,
            thickness: 1,
            color: Colors.black
            )
            ],
            );
        },
      ),
      )
    );
  }
}
