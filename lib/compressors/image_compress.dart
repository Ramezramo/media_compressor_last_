import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
// import '../../../vedioAndPhotosEdited/lib/Utils/Show_Notification.dart';


Future<void> deleteFileInNative(filePath) async {
  const channel = MethodChannel('NativeChannel');
  Map<String, dynamic> arguments = {
    "filepath": filePath,  // Replace with your argument values
  };

  // Pass the arguments when invoking the method
  Map data = await channel.invokeMethod("deleteSource", arguments);


}
Future<void> moveFileInNative(filePath) async {

  const channel = MethodChannel('NativeChannel');
  Map<String, dynamic> arguments = {
    "filepath": filePath,  // Replace with your argument values
  };
  Map data = await channel.invokeMethod("moveScours",arguments);
}

Future<File?> ImageCompressAndGetFile(file, bool deleteSource) async {
  // print("$deleteSource at 987-98789");

  double quality = 20;
  try {
    // print("in 230948_234");
    var perquality;
    if (quality <= 50) {
      perquality = 20;
    } else if (quality >= 50) {
      perquality = 34;
    }

    Uint8List? result = await FlutterImageCompress.compressWithFile(
      file,
      quality: perquality,
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      // Get the external storage directory
      Directory? appDocDir = await getExternalStorageDirectory();

      if (appDocDir != null) {
        // Create the directory if it doesn't exist
        String savePath = '${appDocDir.path}/compressedPhostos';
        Directory(savePath).createSync(recursive: true);

        // Create a new File with the desired file path
        // var datetime = DateTime.now();
        String fileName = path.basename(file);
        File compressedFile = File('$savePath/comp_${fileName}');

        // Write the compressed image data to the file
        await compressedFile.writeAsBytes(result);

        // Check if the file was successfully saved
        if (await compressedFile.exists()) {
          moveFileInNative(compressedFile.path);
          if (deleteSource){
            // print("deleting 345_2352345");
            // print("id 578_67867");
            // print(file);
            deleteFileInNative(file);
          }

          // view message here after compressing
        } else {
          print('Failed to save the compressed image.');
        }
      } else {
        print('External storage directory is null. Unable to save the compressed image.');
      }
    } else {
      print('Compression failed. Result is null.');
    }


  }
   catch (e) {
    // if (kDebugMode) {
    //   // print("hola");
    //   // print(e.toString());
    // }
    // if (kDebugMode) {
    //
    // }
    Fluttertoast.showToast(msg: 'Compression failed');
}
  return null;}

