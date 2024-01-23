import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:video_compress/video_compress.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

Future<void> moveFileInNative(filePath) async {
  const channel = MethodChannel('NativeChannel');
  // print("STOPCODE SLDKFJSLD_4 i will move the file by the native channel");



  Map<String, dynamic> arguments = {
    "filepath": filePath, // Replace with your argument values
  };

  // Pass the arguments when invoking the method
  Map data = await channel.invokeMethod("moveScours", arguments);
}

Future<void> deleteFileInNative(filePath) async {
  const channel = MethodChannel('NativeChannel');
  Map<String, dynamic> arguments = {
    "filepath": filePath, // Replace with your argument values
  };

  // Pass the arguments when invoking the method
  Map data = await channel.invokeMethod("deleteSource", arguments);
}

Future<void> compressVideo(String filePath, bool deleteSource) async {
  await VideoCompress.setLogLevel(0);
  // print("at 3294_234098");
  // print(filePath);

  try {
    final info = await VideoCompress.compressVideo(
      filePath,
      quality: VideoQuality.Res960x540Quality,
      deleteOrigin: false,
      includeAudio: true,
    );
    // print("STOPCODE SLDKFJSLD_3 compressed and in ${info!.path}");

    print(info!.path);

    moveFileInNative(info.path);
    // if (kDebugMode) {
    //   print(info.path);
    // } // This will print the path to the compressed video
    if (deleteSource) {

      deleteFileInNative(filePath);
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "error in compressing code 1489",
      toastLength: Toast.LENGTH_SHORT, // Duration of the toast
      gravity: ToastGravity.BOTTOM, // Location where the toast should appear
      timeInSecForIosWeb: 1, // Duration for iOS
      backgroundColor: Colors.black, // Background color of the toast
      textColor: Colors.white, // Text color of the toast message
      fontSize: 14, // Font size of the toast message
    );
  }
}
