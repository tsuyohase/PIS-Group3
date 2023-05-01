import 'package:flutter/material.dart';
import 'loginPage.dart';
import '../component/loginButton.dart';
import '../constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:parking_app/screen_model/navitime_provider.dart';
import 'package:parking_app/model/navitime.dart';

class NavitimePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(listProvider);
    return Scaffold(
        appBar: new AppBar(
          title: new Text('NAVITIME API！'),
        ),
        body: Center(
          child: asyncValue.when(
            data: (data) {
              return data.isNotEmpty
                  ? ListView(
                      children: data
                          .map(
                            (Navitime navitime) => Card(
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: Text(navitime.name!),
                                        children: [
                                          SimpleDialogOption(
                                            child: Text(
                                                navitime.distance.toString()!),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: ListTile(
                                  title: Text(navitime.name!),
                                  subtitle: Column(
                                    children: [
                                      Text(navitime.distance.toString() + "m"),
                                      Text("capacity" +
                                          navitime.capacity.toString())
                                    ],
                                  ),
                                  trailing: const Icon(Icons.more_vert),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : const Text('Data is empty.');
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text(error.toString()),
          ),
        ));
  }
}
