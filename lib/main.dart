import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';

import 'Pages/PostCompressPage.dart';
import 'compressors/image_compress.dart';
import 'compressors/video_compress.dart';


// comprssorCLASS compress = comprssorCLASS();

void main() {
  runApp(const MyApp());
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


// Future<void> _create_A_main_Folder() async {
//   final channel = const MethodChannel('NativeChannel');
//   await requestStoragePermission();
//   // Map<String, dynamic> arguments = {
//   //   "arg1": "value1",  // Replace with your argument values
//   //   "arg2": "value2",
//   // };
//
//   // Pass the arguments when invoking the method
//   Map data = await channel.invokeMethod("createFolder");
//
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: PostCompression(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int? randomeNumber;
  bool isCompressing_From_Module = false;
  bool userStopedCompressing = false;

  Directory? selectedDirectory;

  double? VideoProgress;
  late Subscription subscription;
  late double? value ;

  late String valueFiltered = "0";



  Future<void>comprssorImage()async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    ImageCompressAndGetFile(pickedFile?.path,false);
  }
  Future<void>comprssorVideo()async{
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    print(pickedFile);
    setState(() {
      if (pickedFile != null)
      isCompressing_From_Module = true;
    });

    await compressVideo(pickedFile!.path,false);
  }
  Future<void> compressAll()async{

  }


@override
  void initState()  {
  subscription= VideoCompress.compressProgress$
      .subscribe((VideoProgress)=>setState(()=>this.VideoProgress=VideoProgress));

  // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    VideoProgress = 0;

  }
  @override
  Widget build(BuildContext context) {
    // if (userStopedCompressing){
    //
    // }
    // getCameraFilesData();
    value =VideoProgress == null? VideoProgress: VideoProgress! /100;

    try{
      print("at 11232309_#@4");
        valueFiltered = value.toString().substring(2, 4);}
    catch(e){
      valueFiltered = "0";
    }
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(onPressed: () async {
              bool grantedPermission = await requestStoragePermission();
              if (grantedPermission){
                comprssorImage();
              }

            }, child: Text("compress photo")),
            isCompressing_From_Module
                ? CircularProgressIndicator() // Display the CircularProgressIndicator while compressing
                : TextButton(
              onPressed: () async {
                // setState(() {
                //
                // });
                // await _create_A_main_Folder();
                bool grantedPermission = await requestStoragePermission();
                if (grantedPermission){
                  await comprssorVideo();
                }



                setState(() {
                  isCompressing_From_Module = false;
                });

              },
              child: Text("Compress Video"),
            ),
            if (isCompressing_From_Module)

              Text(
                "this is the video progress ${valueFiltered}",
              ),
            SizedBox(height: 20),
            if (isCompressing_From_Module) Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Please wait."),
                TextButton(onPressed: (){
                  setState(() {
                    isCompressing_From_Module = false;
                    VideoCompress.cancelCompression();
                    VideoProgress = 0;
                  });
                }, child: Text("stop"))
              ],
            ),
            TextButton(onPressed: () async {
              bool grantedPermission = await requestStoragePermission();
              if (grantedPermission){
                subscription.unsubscribe();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostCompression()));

              }

            }, child: Text("compress all media \nin the camera folder")),
             Text(
              "$randomeNumber",
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // print("pressed");
          // _create_A_main_Folder();
          // comprssorCLASS();
        },
        tooltip: 'add video',
        child: const Icon(Icons.add),
      ),
    );
  }
}
