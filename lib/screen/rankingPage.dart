import 'package:flutter/material.dart';
import 'loginPage.dart';
import '../component/loginButton.dart';
import '../constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:parking_app/screen_model/coffee_provider.dart';
import 'package:parking_app/model/coffee.dart';
import "parking.dart";

import 'package:flutter/material.dart';

///評価バー実装のための準備
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RankingPage extends StatelessWidget {
  final ValueNotifier<List<Parking>> parkings;
  const RankingPage({Key? key, required this.parkings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('Parking Ranking', style: TextStyle(color: Colors.white)),
        ),
        body: Container(
          color: Color.fromARGB(255, 215, 213, 213),
          child: ListView.builder(
            itemCount: parkings.value.length,
            itemBuilder: (context, index) {
              int number = index + 1;
              final parking = parkings.value[index];
              return Column(
                children: [
                  ListTile(
                    title: Text('$number.' + parking.name,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${parking.latLng.latitude}, ${parking.latLng.longitude}',
                              style: TextStyle(color: Colors.black)),
                          
                          ///Text('Congestion: ${parking.congestion}',
                          ///    style: TextStyle(color: Colors.black)),
                          ///Text('Near Roads Width: ${parking.nearWidth}'),
                          RatingBar.builder(
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.white),
                            onRatingUpdate: (rating) {
                              print('${parking.difficulty}');
                            },
                          ),
                          Text(
                              '${parking.distance}km',
                              style: TextStyle(color: Colors.black))
                        ]),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed("/navi", arguments: parking);
                    },
                  ),
                  Divider(height: 2, thickness: 1, color: Colors.black)
                ],
              );
            },
          ),
        ));
  }
}
