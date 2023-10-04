import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../compressors/image_compress.dart';
import '../compressors/video_compress.dart';
import 'Settings/all_media_copier_Settings.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'linear_percent_indicator.dart';
// import 'package:percent_indicator_example/sample_linear_page.dart';

class PostCompression extends StatefulWidget {
  // Map map_of_Files;
  PostCompression();

  @override
  State<PostCompression> createState() => _PostCompressionState();
}
bool isSwitched = false;
class _PostCompressionState extends State<PostCompression> {
  var value;
  Map sortedMap = {};
  bool load = true;
  double progress = 0.0;
  var thumbnail;

  late int totalFiles ;
  int compressed = 0;

  bool compressionFinished = false;
  Uint8List? thumbnailVideo;


  late bool thumbnailPicFunction = false;
  late bool thumbnailVideoFunction = false;


  bool startedCompressingAvideo = false;

  String? fileUnderCompress = "no files yet";


  double? VideoProgress = 0.0;
  late Subscription subscription;

  late double? value2 ;

  late String valueFiltered = "0";

  late bool viewSettingsButtonsBeforePresssing = true;

  // late bool isSwitched = false;

  void progress_maker() async {

      progress = compressed / totalFiles;
      setState(() {});

  }

  void videoProgressMaker(done,total) async {

    VideoProgress = done / total;
    setState(() {});

  }
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission is granted; you can now access the directory
      return true;
    } else if (status.isPermanentlyDenied) {
      // The user has permanently denied the permission, you can open the app settings
      await openAppSettings();
      return false;

    } else {
      // Permission is denied
      return false;
    }
  }
  Future<Map> getCameraFilesData() async {
    print("in get cam data ");
    const channel = MethodChannel('NativeChannel');
    await requestStoragePermission();


    // Pass the arguments when invoking the method
    Map data = await channel.invokeMethod("giveMEcameraData");
    int i = 0;

    List<MapEntry<dynamic, dynamic>> sortedEntries = data.entries.toList();

    sortedEntries.sort((a, b) {
      // Assuming the values are comparable, e.g., they are numbers or strings
      return a.value.compareTo(b.value);
    });

    sortedMap = Map.fromEntries(sortedEntries);


    sortedMap.forEach((key, value) {
      i ++;
      print(key); // This will print the keys
      print(value); // This will print the corresponding values
      print(i);
    });
    // print(data);
    setState(() {
      load = false;
    });
    totalFiles = sortedMap.length;

    return sortedMap;

  }
  Future<List<File>> getFilesInFolderSortedByDate() async {
    print("at 2342_234234");
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      print("null");
      // Handle the case where external storage is not available
      return [];
    }

    Directory folder = Directory('/storage/emulated/0/DCIM/Camera');
    // print(folder);

    if (!folder.existsSync()) {
      // Handle the case where the folder does not exist
      return [];
    }

    List<File> filesInFolder = folder.listSync().whereType<File>().toList();
    // print(filesInFolder);
    // Sort files by date in ascending order
    filesInFolder.sort((a, b) {
      DateTime dateA = a.lastModifiedSync();
      DateTime dateB = b.lastModifiedSync();
      return dateA.compareTo(dateB);
    });
    // print(filesInFolder);
    return filesInFolder;
  }
  Future<Uint8List?> createVideoThumbnail(String videoPath) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // Set the desired thumbnail width (adjust as needed)
      quality: 25,  // Set the image quality (adjust as needed)
    );
    return thumbnail;
  }


  Future<void>comprssImage(path)async{

    ImageCompressAndGetFile(path,isSwitched);
  }


  Future<void>comprssorVideo(path)async{
    setState(() {
      startedCompressingAvideo = true;
      print("at 3495870");
      print(startedCompressingAvideo);
    });
    await compressVideo(path,isSwitched);
    setState(() {
      VideoProgress = 0;
      startedCompressingAvideo = false;
    });
  }

  Future<void> startCompressing() async {
    print("in start compressing");

    for (final entry in sortedMap.entries) {
      final key = entry.key;
      final value = entry.value;
      setState(() {
        viewSettingsButtonsBeforePresssing = false;
      });

      if (key.endsWith(".jpg")) {
        print(key); // This will print the keys that end with ".jpg"
        setState(() {
          fileUnderCompress = key;
          thumbnailVideoFunction = false;
          thumbnailPicFunction = true;
          thumbnail = key;
          print(thumbnail);
        });

        await comprssImage(key);
        setState(() {

          compressed++;
          progress_maker();
        });
      } else if (key.endsWith(".mp4")) {
        print(key); // This will print the keys that end with ".mp4"
        thumbnailVideo = await createVideoThumbnail(key);
        setState(() {
          fileUnderCompress = key;
          thumbnailPicFunction = false;
          thumbnailVideoFunction = true;

        });
        await comprssorVideo(key);
        setState(() {
          compressed++;
          progress_maker();
        });
      }

    }
    Fluttertoast.showToast(
      msg: "Compression complete successfully",
      toastLength: Toast.LENGTH_SHORT, // Duration of the toast
      gravity: ToastGravity.BOTTOM,    // Location where the toast should appear
      timeInSecForIosWeb: 1,          // Duration for iOS
      backgroundColor: Colors.black,   // Background color of the toast
      textColor: Colors.white,        // Text color of the toast message
      fontSize: 14,                 // Font size of the toast message
    );
    setState(() {
      compressionFinished = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initSta

    getCameraFilesData();
    subscription= VideoCompress.compressProgress$
        .subscribe((VideoProgress)=>setState(()=>this.VideoProgress=VideoProgress));

    // progress_maker();
    // totalFiles = sortedMap.length;
    super.initState();
  }

  @override
  void dispose() {
    // Dispose of resources to prevent memory leaks.
    subscription.unsubscribe(); // Close the stream controller.


    super.dispose();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }





  @override
  Widget build(BuildContext context) {
    // print("in 23425424234");
    // getFilesInFolderSortedByDate();
    value2 =VideoProgress == null? VideoProgress: VideoProgress! /100;

    try{
      print("at 11232309_#@4");
      valueFiltered = value2.toString().substring(2, 4);
      int? intValue = int.tryParse(valueFiltered);
      setState(() {
        videoProgressMaker(intValue,99);
      });

    }

    catch(e){
      valueFiltered = "0";
    }
    return Scaffold(
      backgroundColor:Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        title: Text('Compressor'),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage_3()));
          }, icon: Icon(Icons.settings))
        ],
      ),
      body: Column(children: [
        if (thumbnailPicFunction)
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2.5,
          child: Image.file(
            File(thumbnail),
            fit: BoxFit.contain,
          ),
        ),
        if (thumbnailVideoFunction)
          Image.memory(
            thumbnailVideo!,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2.5,
          fit: BoxFit.contain,
          ),
        if (!thumbnailPicFunction && !thumbnailVideoFunction)
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.5,
            child: Image.asset(
              "images/Screenshot (10).png",
              fit: BoxFit.contain,
            ),
          ),


        SizedBox(
          height: 10,
        ),
        LinearProgressIndicator(
          minHeight: 9,
          value: progress, // Set the progress value (0.0 to 1.0)
          backgroundColor: Colors.grey, // Optional: Background color
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent), // Optional: Progress color
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.all(15.0),
          child: LinearPercentIndicator(
            width: MediaQuery.of(context).size.width - 50,
            animation: true,
            lineHeight: 20.0,
            animationDuration: 2500,
            percent: 0.8,
            center: Text("80.0%"),
            linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: Colors.green,
          ),
        ),



        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (load)
              CircularProgressIndicator()
            else
            Text(
              'compressed: ' + compressed.toString(),
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              width: 20,
            ),
            if (load)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CircularProgressIndicator(),
              )
            else
            Text(
              'totalFiles: ' + totalFiles.toString(),
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w400),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        // if (startedCompressingAvideo)
        //   CircularProgressIndicator(),
        if (!compressionFinished)
          Text("file name ($fileUnderCompress)",style: TextStyle(color: Colors.black87)),
        if (compressionFinished)




          Icon(Icons.check,color: Colors.green,),

        if (viewSettingsButtonsBeforePresssing)
          buildAnimatedButton(context),






        if (viewSettingsButtonsBeforePresssing)
        Container(color: Colors.white.withOpacity(0.8),child: TextButton(onPressed: (){
          startCompressing();
          print("start compressing pressed");

          print(value);
        }, child: Text("Start Compressing")))
      ]),
    );
  }

  Container buildAnimatedButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: AnimatedButton(
            text: 'compress settings',
            color: Colors.deepPurple,
            pressEvent: () {
              // AwesomeDialog(
              //   context: context,
              //   animType: AnimType.SCALE,
              //   customHeader: Icon(
              //     Icons.settings,
              //     size: 50,
              //   ),
              //   btnOk: Column(
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Text(
              //             "delete the source file",
              //             style: TextStyle(fontSize: 15, color: Colors.black),
              //           ),
              //           Switch(
              //             value: isSwitched,
              //             onChanged: (value) {
              //               setState(() {
              //                 isSwitched = value; // Update the state variable when the switch is toggled.
              //
              //               });
              //             },
              //           ),
              //         ],
              //       ),
              //       IconButton(
              //         icon: Icon(Icons.keyboard_return),
              //         onPressed: () {
              //           Navigator.of(context).pop();
              //         },
              //       ),
              //     ],
              //   ),
              //   btnOkOnPress: () {
              //     showDialog(
              //       context: context,
              //       builder: (context) {
              //         return StatefulAlertDialog();
              //       },
              //     );
              //
              //   },
              // )
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulAlertDialog();
                },
              );
            },
          ),
    );
  }
}

class StatefulAlertDialog extends StatefulWidget {
  @override
  _StatefulAlertDialogState createState() => _StatefulAlertDialogState();
}


class _StatefulAlertDialogState extends State<StatefulAlertDialog> {


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Stateful Alert Dialog"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Delete the source code",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value; // Update the state variable when the switch is toggled.

                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        ),
      ],
    );
  }
}
