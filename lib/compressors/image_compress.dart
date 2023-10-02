import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
// import '../../../vedioAndPhotosEdited/lib/Utils/Show_Notification.dart';



Future<void> moveFileInNative(filePath) async {
  final channel = const MethodChannel('NativeChannel');

  Map data = await channel.invokeMethod(filePath);

}

Future<File?> ImageCompressAndGetFile(file, bool deleteSource) async {
  double quality = 20;
  try {
    print("in 230948_234");
    var perquality;
    if (quality <= 50) {
      perquality = 20;
    } else if (quality >= 50) {
      perquality = 34;
    }


    // var folderPath = '${appDocDir!.path}/0/RamezCompressed/photos';
    // Directory(folderPath).createSync(recursive: true);
    //

    // final pathOfImage =
    // File('$folderPath/${datetime}_compressed.jpeg');
    // print("in 3495_34580");
  //   var result = await FlutterImageCompress.compressWithFile(
  //     file,
  //     quality: perquality,
  //     format: CompressFormat.jpeg,
  //   );
  //
  //   if (result != null) {
  //     // Create a new File with the desired file path
  //     var appDocDir = await getExternalStorageDirectory();
  //     File compressedFile = File('${appDocDir}/path_to_save/compressed_image.jpg');
  //
  //     // Write the compressed image data to the file
  //     await compressedFile.writeAsBytes(result);
  //
  //     // Check if the file was successfully saved
  //     if (await compressedFile.exists()) {
  //       print('Compressed image saved at: ${compressedFile.path}');
  //     } else {
  //       print('Failed to save the compressed image.');
  //     }
  //   } else {
  //     print('Compression failed. Result is null.');
  //   }
  //   // print("at 987_098707");
  //   // print(pathOfImage.path);
  //
  //   // moveFileInNative(pathOfImage.path);
  //   // GallerySaver.saveImage(pathOfImage.path);
  //
  //

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
          // print('Compressed image saved at: ${compressedFile.path}');
          // Fluttertoast.showToast(
          //   msg: "the photo compressed in MyFolder",
          //   toastLength: Toast.LENGTH_SHORT, // Duration of the toast
          //   gravity: ToastGravity.BOTTOM,    // Location where the toast should appear
          //   timeInSecForIosWeb: 1,          // Duration for iOS
          //   backgroundColor: Colors.black,   // Background color of the toast
          //   textColor: Colors.white,        // Text color of the toast message
          //   fontSize: 10.0,                 // Font size of the toast message
          // );
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
    print("hola");
    print(e.toString());
    Fluttertoast.showToast(msg: 'Compression failed');
}}

