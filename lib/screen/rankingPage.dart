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

class StaticRatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final bool allowHalfRating;

  StaticRatingBar({
    required this.rating,
    this.size = 24.0,
    this.color = Colors.yellow,
    this.allowHalfRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (allowHalfRating) {
          if (rating >= index && rating < index + 1) {
            return Icon(
              Icons.star_half,
              size: size,
              color: color,
            );
          }
        }
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          size: size,
          color: color,
        );
      }),
    );
  }
}

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
                    title: Text('$number. ' + parking.name,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //     '${parking.latLng.latitude}, ${parking.latLng.longitude}',
                          //     style: TextStyle(color: Colors.black)),

                          ///Text('Congestion: ${parking.congestion}',
                          ///    style: TextStyle(color: Colors.black)),
                          ///Text('Near Roads Width: ${parking.nearWidth}'),
                          StaticRatingBar(
                            rating:
                                parking.difficulty * 5, // 0から1までの数値を5倍した評価値を指定
                            size: 20.0, // 星のサイズを指定
                            color: Colors.white, // 星の色を指定
                            allowHalfRating: true, // 半分の星を許可する
                          ),
                          Text('${parking.distance}km',
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
