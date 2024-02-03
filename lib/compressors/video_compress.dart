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

import '../Pages/homePage/home_Page.dart';

Future<String> moveFileInNative(filePath) async {
  const channel = MethodChannel('NativeChannel');
  // print("STOPCODE SLDKFJSLD_4 i will move the file by the native channel");



  Map<String, dynamic> arguments = {
    "filepath": filePath, // Replace with your argument values
  };

  // Pass the arguments when invoking the method
  var data = await channel.invokeMethod("moveScours", arguments);
  print("CODE SLDKJFDSF");
  return data.toString();
}

Future<void> deleteFileInNative(filePath) async {
  const channel = MethodChannel('NativeChannel');
  Map<String, dynamic> arguments = {
    "filepath": filePath, // Replace with your argument values
  };

  // Pass the arguments when invoking the method
  Map data = await channel.invokeMethod("deleteSource", arguments);
}

Future<void> compressVideo(String userVideoQuality ,String filePath, bool deleteSource) async {
  await VideoCompress.setLogLevel(0);
  // print("at 3294_234098");
  // print(filePath);
  VideoQuality? selectedQuality;
  if (userVideoQuality == "360p") {
    selectedQuality = VideoQuality.LowQuality;}
  if (userVideoQuality == "480p") {
    selectedQuality = VideoQuality.Res640x480Quality;}
  else if (userVideoQuality == "540p") {
    selectedQuality = VideoQuality.Res960x540Quality;
  } else if (userVideoQuality == "720p") {
    selectedQuality = VideoQuality.Res1280x720Quality;
  } else if (userVideoQuality == "1080p") {
    selectedQuality = VideoQuality.Res1920x1080Quality;
  }  else {
    // Handle the case when userVideoQuality is neither "480" nor "720"
    selectedQuality = VideoQuality.Res960x540Quality;
  }


  try {

    final info = await VideoCompress.compressVideo(
      filePath,
      quality: selectedQuality,
      deleteOrigin: false,
      includeAudio: true,
    );


    print(info!.path);
    ///to get the main file modified date
    File file = File(filePath);
    DateTime originalModificationTime = await file.lastModified();
    ///to get the main file modified date



    int fileSizeBeforeCompress = await file.length();
    filesSizeBeforeCompressFromHomePage += fileSizeBeforeCompress;

    String FileCompressedAndMovedPath = await moveFileInNative(info.path);
    File filePP = File(FileCompressedAndMovedPath);

    int fileSizeAfterCompress = await filePP.length();
    filesSizeAfterCompressFromHomePage += fileSizeAfterCompress;
    print("CODE LKSDJFLSKDJF");
    print("$fileSizeBeforeCompress before $fileSizeAfterCompress after");
    await filePP.setLastModified(originalModificationTime);
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
