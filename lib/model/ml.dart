import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class MachineLearning {
  static Future<FirebaseCustomModel> getModel() async {
    FirebaseCustomModel customModel =
        await FirebaseModelDownloader.instance.getModel(
            "parking_model_smote",
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
    final Interpreter interpreter = Interpreter.fromFile(customModel.file);
    // final Interpreter interpreter =
    //     await Interpreter.fromAsset('sample.tflite');

    // if output tensor shape [1,2] and type is float32.
    // Object output = List.filled(1 * 2, 0).reshape([1, 2]);
    var output = List.filled(1 * 2, 0).reshape([1, 2]);
    interpreter.run([input], output);
    interpreter.close();
    return output;
  }

  static List<double> standardScaler(List<double> input) {
    final List<double> deviations = [
      6.46271209e+02,
      2.49325350e-01,
      2.43928150e-01,
      6.91178951e-01
    ];
    final List<double> means = [
      11.03896104,
      0.47402597,
      0.57792208,
      1.48051948
    ];
    List<double> result = [];
    for (int i = 0; i < input.length; i++) {
      result.add((input[i] - means[i]) / deviations[i]);
    }
    return result;
  }
}
