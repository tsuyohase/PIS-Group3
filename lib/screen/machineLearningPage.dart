import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MachineLearningPage extends StatefulWidget {
  const MachineLearningPage({super.key});

  @override
  State<MachineLearningPage> createState() => _MachineLearningPage();
}

class _MachineLearningPage extends State<MachineLearningPage> {
  late FirebaseCustomModel cm;
  late dynamic inputData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('機械学習ページ'),
        ),
        body: Column(children: [
          ElevatedButton(
            child: const Text('学習モデルダウンロード'),
            onPressed: () async {
              cm = await MachineLearning.getModel();
              debugPrint("CustomModel's name: ${cm.name}");
              debugPrint("CustomModel's file: ${cm.file}");
            },
          ),
          ElevatedButton(
            child: const Text('入力データ設定'),
            onPressed: () async {
              inputData = await MachineLearning.getInputData();
              debugPrint("Get Inpput Data!");
            },
          ),
          ElevatedButton(
            child: const Text('処理開始'),
            onPressed: () async {
              Object predDifficulty =
                  await MachineLearning.runProcessResult(cm, inputData);
              debugPrint("Difficulty: $predDifficulty");
            },
          ),
        ]));
  }
}

class MachineLearning {
  static Future<FirebaseCustomModel> getModel() async {
    FirebaseCustomModel customModel =
        await FirebaseModelDownloader.instance.getModel(
            "sample-tani",
            FirebaseModelDownloadType.localModel,
            FirebaseModelDownloadConditions(
              iosAllowsCellularAccess: true,
              iosAllowsBackgroundDownloading: false,
              androidChargingRequired: false,
              androidWifiRequired: false,
              androidDeviceIdleRequired: false,
            ));
    debugPrint("customModel is downloaded!");
    return customModel;
  }

  static Future<Object> runProcessResult(
      FirebaseCustomModel customModel, var input) async {
    debugPrint("Processing...");
    final Interpreter interpreter =
        Interpreter.fromFile(File(customModel.name));
    // if output tensor shape [1,2] and type is float32.
    // Object output = List.filled(1 * 2, 0).reshape([1, 2]);
    dynamic output;
    interpreter.run(input, output);
    interpreter.close();
    return output;
  }

  static getInputData() {
    Object inputData = "default";
    return inputData;
  }
}
