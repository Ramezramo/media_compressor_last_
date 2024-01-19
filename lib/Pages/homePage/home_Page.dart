import 'dart:io';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_video_compressor_last/Pages/src/panel.dart';

import 'package:flutter/services.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../compressors/image_compress.dart';
import '../../compressors/video_compress.dart';
import '../../main.dart';
import '../linear_percent_indicator.dart';

// import 'engine/pagevoids.dart';
// import 'engine/pagevoids.dart';
Future<void> showTost(text) async {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT, // Duration of the toast
    gravity: ToastGravity.BOTTOM, // Location where the toast should appear
    timeInSecForIosWeb: 1, // Duration for iOS
    backgroundColor: Colors.black, // Background color of the toast
    textColor: Colors.white, // Text color of the toast message
    fontSize: 14, // Font size of the toast message
  );
}

class MainHomePage extends StatefulWidget {
  @override
  _MainHomePageState createState() => _MainHomePageState();
}

bool isSwitched = false;
const channel = MethodChannel('NativeChannel');

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

Future<void> comprssorImageone() async {
  requestStoragePermission();
  final picker = ImagePicker();
  print("id 89_097809099");
  print(isSwitched);
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) ImageCompressAndGetFile(pickedFile?.path, isSwitched);
  if (pickedFile != null)
    showTost("image saved in /storage/emulated/0/Compressed_media_RM");
}

class _MainHomePageState extends State<MainHomePage> {
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 95.0;

  /// this map will contain a files sorted by date from the native channel
  Map map_Contains_Files_Names_Sorted_By_Date = {};

  /// if true will view loading indicator
  bool load = true;

  /// video compressing progress
  double progress = 0.0;

  /// the path of the generated thumbnail will be stored in this var
  Uint8List? thumbnailVideoPath;
  var thumbnail;

  /// for files in camera count obtained from the native channel
  late int total_Files_Length_Obtained_From_NATIVE = 0;

  /// total compressed files
  int compressed = 0;

  /// if compressing finished view the true widget and view a widget
  /// to tell the user the compressing process finished
  bool compressionFinished = false;

  late bool thumbnailPicFunction = false;
  late bool thumbnailVideoFunction = false;

  bool startedCompressingAvideo = false;

  String? fileUnderCompress = "no files yet";

  double? VideoProgress = 0.0;
  late Subscription subscription;

  late double? video_Compressing_Percentage;

  late String video_Compressing_Percentage_Filtered = "0";

  late bool viewSettingsButtonsBeforePresssing = true;
  bool startedCompressingProsses = false;
  var isCompressing_From_Module = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool preparingFileToCompress = false;
  bool firsPageIdentifier = true;
  void restarter() {
    bool preparingFileToCompress = false;
    startedCompressingProsses = false;
    // value;
    map_Contains_Files_Names_Sorted_By_Date = {};
    load = true;
    progress = 0.0;
    thumbnail;

    total_Files_Length_Obtained_From_NATIVE = 0;
    compressed = 0;

    compressionFinished = false;
    thumbnailVideoPath;

    thumbnailPicFunction = false;
    thumbnailVideoFunction = false;

    startedCompressingAvideo = false;

    fileUnderCompress = "no files yet";

    VideoProgress = 0.0;
    subscription;

    video_Compressing_Percentage;

    video_Compressing_Percentage_Filtered = "0";

    viewSettingsButtonsBeforePresssing = true;
    getCameraFilesData();
  }

  Future<String?> getFilePathFromContentUri(String contentUri) async {
    try {
      final String? filePath =
          await channel.invokeMethod('getFilePath', {'uri': contentUri});
      return filePath;
    } catch (e) {
      print('Error getting file path: $e');
      return null;
    }
  }

  Future<void> comprssorVideoone() async {
    requestStoragePermission();
    final picker = ImagePicker();
    setState(() {
      preparingFileToCompress = true;
    });

    // FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    // String? videoPath = result?.files.single.path;
    // print("id 09ew70097 $videoPath");
    //
    // final filePath = await getFilePathFromContentUri(videoPath!);
    // print('Selected video path: $filePath');

    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    print(pickedFile);
    setState(() {
      preparingFileToCompress = false;
      if (pickedFile != null) isCompressing_From_Module = true;
    });

    if (pickedFile != null) {
      //
      print("id 89_097809099");
      print(isSwitched);
      await compressVideo(pickedFile!.path, isSwitched);
    }
    setState(() {
      isCompressing_From_Module = false;
    });

    if (pickedFile != null)
      showTost("video saved in /storage/emulated/0/Compressed_media_RM");
  }

  void progress_maker() async {
    progress = compressed / total_Files_Length_Obtained_From_NATIVE;
    setState(() {});
  }

  void videoProgressMaker(done, total) async {
    var VideoProgress = done / total;
    print(VideoProgress);
    setState(() {});
  }

  Future<Map> getCameraFilesData() async {
    print("in get cam data ");

    await requestStoragePermission();

    // Pass the arguments when invoking the method
    Map data = await channel.invokeMethod("giveMEcameraData");
    int i = 0;

    List<MapEntry<dynamic, dynamic>> sortedEntries = data.entries.toList();

    sortedEntries.sort((a, b) {
      // Assuming the values are comparable, e.g., they are numbers or strings
      return a.value.compareTo(b.value);
    });

    map_Contains_Files_Names_Sorted_By_Date = Map.fromEntries(sortedEntries);

    map_Contains_Files_Names_Sorted_By_Date.forEach((key, value) {
      i++;
      print(key); // This will print the keys
      print(value); // This will print the corresponding values
      print(i);
    });
    // print(data);
    setState(() {
      load = false;
    });
    total_Files_Length_Obtained_From_NATIVE =
        map_Contains_Files_Names_Sorted_By_Date.length;

    return map_Contains_Files_Names_Sorted_By_Date;
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
    var thumbnail = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // Set the desired thumbnail width (adjust as needed)
      quality: 25, // Set the image quality (adjust as needed)
    );
    return thumbnail;
  }

  Future<void> comprssImage(path) async {
    ImageCompressAndGetFile(path, isSwitched);
  }

  Future<void> comprssorVideo(path) async {
    setState(() {
      startedCompressingAvideo = true;
      print("at 3495870");
      print(startedCompressingAvideo);
    });
    await compressVideo(path, isSwitched);
    setState(() {
      VideoProgress = 0;
      startedCompressingAvideo = false;
    });
  }

  Future<void> startCompressing() async {
    print("in start compressing");
    setState(() {
      startedCompressingProsses = true;

    });
    for (final entry in map_Contains_Files_Names_Sorted_By_Date.entries) {
      final key = entry.key;
      final value = entry.value;
      setState(() {
        viewSettingsButtonsBeforePresssing = false;
      });

      if (key.endsWith(".jpg") ||
          key.endsWith(".jpeg") ||
          key.endsWith(".png") ||
          key.endsWith(".gif") ||
          key.endsWith(".webp")) {
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
      } else if (key.endsWith(".mp4") ||
          key.endsWith(".mov") ||
          key.endsWith(".mkv") ||
          key.endsWith(".avi")) {
        print(key); // This will print the keys that end with ".mp4"
        thumbnailVideoPath = await createVideoThumbnail(key);
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
    showTost("Compression complete successfully");
    setState(() {
      startedCompressingProsses = false;
      compressionFinished = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initSta
    if (!kIsWeb) {
      getCameraFilesData();
      subscription = VideoCompress.compressProgress$.subscribe(
          (VideoProgress) =>
              setState(() => this.VideoProgress = VideoProgress));
      _fabHeight = _initFabHeight;
    }
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

  @override
  Widget build(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;
    video_Compressing_Percentage =
        VideoProgress == null ? VideoProgress : VideoProgress! / 100;

    try {
      print("at 11232309_#@4");
      video_Compressing_Percentage_Filtered =
          video_Compressing_Percentage.toString().substring(2, 4);
      int? intValue = int.tryParse(video_Compressing_Percentage_Filtered);
      setState(() {
        videoProgressMaker(intValue, 99);
      });
    } catch (e) {
      video_Compressing_Percentage_Filtered = "0";
    }
    return Material(
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SlidingUpPanel(
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            body: _body(),
            panelBuilder: (sc) => _panel(sc),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            onPanelSlide: (double pos) => setState(() {
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
          ),

          // the fab
          Positioned(
            right: 20.0,
            bottom: _fabHeight,
            child: settingFloatingButton(),
          ),

          Positioned(
              top: 0,
              child: ClipRRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).padding.top,
                        color: Colors.transparent,
                      )))),
        ],
      ),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            const SizedBox(
              height: 12.0,
            ),
            aRowWithBoxDecoration(),
            const SizedBox(
              height: 18.0,
            ),
            aRowContainsSwipeUpText(),
            const SizedBox(
              height: 36.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.15),
                                  blurRadius: 8.0,
                                )
                              ]),
                          child: singleImageCompressor(),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("COMPRESS photo"),
                      ],
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                    if (preparingFileToCompress)
                      CircularProgressIndicator()
                    else if (!isCompressing_From_Module)
                      Column(
                        children: [
                          containerForPickingVideoIcon(),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("COMPRESS Video"),
                        ],

                        // percent: ,
                        // center: ,
                      )
                    else
                      circularPercentIndicator(),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Media will be compressed",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: copyRightSection(),
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ));
  }

  Container containerForPickingVideoIcon() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              blurRadius: 8.0,
            )
          ]),
      child: IconButton(
        icon: Icon(Icons.video_collection_rounded),
        color: Colors.white,
        onPressed: () {
          comprssorVideoone();
        },
      ),
    );
  }

  CircularPercentIndicator circularPercentIndicator() {
    return CircularPercentIndicator(
      radius: 40.0,
      lineWidth: 10.0,
      // animation: true,
      percent: double.parse("0.${video_Compressing_Percentage_Filtered}"),
      center: Text(
        "%$video_Compressing_Percentage_Filtered",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      footer: IconButton(
        icon: const Icon(Icons.cancel),
        onPressed: () {
          setState(() {
            isCompressing_From_Module = false;
            VideoCompress.cancelCompression();
            // VideoProgress = 0;
          });
        },
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.purple,
    );
  }

  Widget _body() {
    String progressH;
    try {
      progressH = progress.toString()[2];
    } catch (r) {
      progressH = "no";
    }

    return SafeArea(
      child: Scaffold(
        body: Column(children: [

          if (firsPageIdentifier)
            firstPageWidget(cameraFiles: total_Files_Length_Obtained_From_NATIVE.toString(),OnPressed:  () {
              print("restart");
              setState(() {
                restarter();
              });
            }),if (startedCompressingProsses  )
            startedCompressingProssesWidget(thumbnail: thumbnail,cameraFiles:total_Files_Length_Obtained_From_NATIVE.toString() , filesCompressed: '', totalFilesPercentage: '', currentFilePercentage: '', compressingVideo: false,),//else if (startedCompressingProsses || !thumbnailPicFunction )startedCompressingProssesWidget(cameraFiles:total_Files_Length_Obtained_From_NATIVE.toString() , filesCompressed: '', totalFilesPercentage: '', currentFilePercentage: '', compressingVideo: true, thumbnail: thumbnailVideoPath,),

          // if (thumbnailPicFunction)
          //   pictureThumbNail(context: context, thumbnail: thumbnail),
          // if (thumbnailVideoFunction)
          // videoThumbnail(
          //     thumbnailVideoPath: thumbnailVideoPath, context: context),
          // if (!thumbnailPicFunction && !thumbnailVideoFunction)
          //   WaitingThumbNail(context: context),
          // const SizedBox(
          //   height: 10,
          // ),

          // rowOfTextOfCompressedFilesNum(),
          // linearPercentIndicatorWithPadding(
          //     context: context,
          //     video_Compressing_Percentage_Filtered:
          //         video_Compressing_Percentage_Filtered),
          //
          // const SizedBox(
          //   height: 10,
          // ),
          //
          // if (!compressionFinished)
          //   textOfFileBeingCompressedName(fileUnderCompress: fileUnderCompress),
          // if (compressionFinished) TheIconOFDone(),
          //
          if (viewSettingsButtonsBeforePresssing)
            StartCompressongButton(context)
          // else if (!viewSettingsButtonsBeforePresssing &&
          //     startedCompressingProsses)
          //   TheButtonOfStop()
          // if (viewSettingsButtonsBeforePresssing)
          // Container(color: Colors.white.withOpacity(0.8),child: TextButton(onPressed: (){
        ]),
      ),
    );
  }



  Container StartCompressongButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: AnimatedButton(
        text: 'Start Compressing',
        color: Colors.deepPurple,
        pressEvent: () {
          if (!kIsWeb) {
            setState(() {
              firsPageIdentifier = false;
            });
            startCompressing();

          }
        },
      ),
    );
  }
}

class startedCompressingProssesWidget extends StatelessWidget {
  final bool? compressingVideo;
  final String totalFilesPercentage;

  final String  currentFilePercentage;
  final String cameraFiles ;

  final String filesCompressed;
  final thumbnail;

  const startedCompressingProssesWidget({super.key, required this.cameraFiles,required this.filesCompressed,required this.totalFilesPercentage,required this.currentFilePercentage, required this.compressingVideo,required this.thumbnail});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (pictureThumbNail == false)
    videoThumbnail(
        thumbnailVideoPath: thumbnail, context: context)else

          pictureThumbNail(context: context, thumbnail: thumbnail),
        linearPercentIndicatorWithPadding(
            context: context,
            video_Compressing_Percentage_Filtered: "00"),
        linearPercentIndicatorWithPadding(
            context: context,
            video_Compressing_Percentage_Filtered: "00"),
      ],
    );
  }
}

class firstPageWidget extends StatelessWidget {
  const firstPageWidget({super.key,required this.OnPressed, required this.cameraFiles});
  final void Function()? OnPressed;
  final String cameraFiles ;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WaitingThumbNail(context: context),
        linearPercentIndicatorWithPadding(
            context: context,
            video_Compressing_Percentage_Filtered: "00"),
        rowOfTextOfCompressedFilesNum(OnPressed: OnPressed, compressorIsRunning: false ,compressed: "",total_Files_Length: cameraFiles,),
        linearPercentIndicatorWithPadding(
            context: context,
            video_Compressing_Percentage_Filtered: "00"),
      ],
    );
  }
}

class reloadButton extends StatelessWidget {
   const reloadButton({super.key, this.OnPressed});
  final void Function()? OnPressed;
  @override
  Widget build(BuildContext context) {
    return  IconButton(
      onPressed: OnPressed,
      icon: const Icon(Icons.refresh),
    );
  }
}

class rowOfTextOfCompressedFilesNum extends StatelessWidget {
  const rowOfTextOfCompressedFilesNum({super.key, this.OnPressed, required this.compressorIsRunning, required this.compressed, required this.total_Files_Length});
  final void Function()? OnPressed;
  final bool compressorIsRunning;
  final String compressed;
  final String total_Files_Length;
  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        if (compressorIsRunning)
          Text(
            '$compressed files compressed from $total_Files_Length',
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w400),
          )
        else if (!compressorIsRunning)
          Text(
            'camera files: $total_Files_Length',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w400),
          ),
        const SizedBox(
          width: 20,
        ),
          reloadButton(OnPressed: OnPressed)
      ],
    );;
  }
}

// Row rowOfTextOfCompressedFilesNum() {
//   return
// }

class linearPercentIndicatorWithPadding extends StatelessWidget {
  const linearPercentIndicatorWithPadding({
    super.key,
    required this.context,
    required this.video_Compressing_Percentage_Filtered,
  });

  final BuildContext context;
  final String video_Compressing_Percentage_Filtered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7,right: 7, left: 7, bottom: 7),
      child: linearPercentIndicator(
          context: context,
          video_Compressing_Percentage_Filtered:
              video_Compressing_Percentage_Filtered),
    );
  }
}

class pictureThumbNail extends StatelessWidget {
  const pictureThumbNail({
    super.key,
    required this.context,
    required this.thumbnail,
  });

  final BuildContext context;
  final thumbnail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2.5,
      child: Image.file(
        File(thumbnail),
        fit: BoxFit.contain,
      ),
    );
  }
}

class videoThumbnail extends StatelessWidget {
  const videoThumbnail({
    super.key,
    required this.thumbnailVideoPath,
    required this.context,
  });

  final Uint8List? thumbnailVideoPath;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      thumbnailVideoPath!,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2.5,
      fit: BoxFit.contain,
    );
  }
}

class TheButtonOfStop extends StatelessWidget {
  const TheButtonOfStop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.stop_circle_rounded),
      iconSize: 45,
      color: Colors.red,
      onPressed: () {},
    );
  }
}

class TheIconOFDone extends StatelessWidget {
  const TheIconOFDone({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.check,
      color: Colors.green,
    );
  }
}

class textOfFileBeingCompressedName extends StatelessWidget {
  const textOfFileBeingCompressedName({
    super.key,
    required this.fileUnderCompress,
  });

  final String? fileUnderCompress;

  @override
  Widget build(BuildContext context) {
    return Text("file name ($fileUnderCompress)",
        style: const TextStyle(color: Colors.black87));
  }
}

class WaitingThumbNail extends StatelessWidget {
  const WaitingThumbNail({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2.5,
      child: Image.asset(
        "images/just-waitin-waitin.gif",
        fit: BoxFit.contain,
      ),
    );
  }
}

class linearPercentIndicator extends StatelessWidget {
  const linearPercentIndicator({
    super.key,
    required this.context,
    required this.video_Compressing_Percentage_Filtered,
  });

  final BuildContext context;
  final String video_Compressing_Percentage_Filtered;

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      width: MediaQuery.of(context).size.width - 50,
      // animation: true,
      lineHeight: 20.0,
      // animationDuration: 1000,
      percent: double.parse("0.$video_Compressing_Percentage_Filtered"),
      center: Text("%$video_Compressing_Percentage_Filtered"),
      linearStrokeCap: LinearStrokeCap.roundAll,
      progressColor: Colors.green,
    );
  }
}

class settingFloatingButton extends StatelessWidget {
  const settingFloatingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulAlertDialog();
          },
        );
      },
      backgroundColor: Colors.white,
      child: Icon(
        Icons.settings,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class copyRightSection extends StatelessWidget {
  const copyRightSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("About",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            )),
        SizedBox(
          height: 12.0,
        ),
        textForCopyRight(),
      ],
    );
  }
}

class textForCopyRight extends StatelessWidget {
  const textForCopyRight({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      """ Copyright © RAMEZMALAK 2023/10/1

All rights reserved. This application and its content are protected by copyright law. The content, including but not limited to text, graphics, images, and software code, is the property of RAMEZMALAK.CORP. Any unauthorized use or reproduction of this content without permission is prohibited.

For inquiries regarding the use or licensing of this content, please contact ramezmfarouk@gmail.com.

RAMEZMALAK.CORP reserves the right to take legal action against any unauthorized use or infringement of its intellectual property rights.

Thank you for respecting our intellectual property.
 """,
      softWrap: true,
    );
  }
}

class aRowContainsSwipeUpText extends StatelessWidget {
  const aRowContainsSwipeUpText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        swipeText(),
      ],
    );
  }
}

class aRowWithBoxDecoration extends StatelessWidget {
  const aRowWithBoxDecoration({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 30,
          height: 5,
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
        ),
      ],
    );
  }
}

class singleImageCompressor extends StatelessWidget {
  const singleImageCompressor({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.photo),
      color: Colors.white,
      onPressed: () {
        comprssorImageone();
      },
    );
  }
}

class swipeText extends StatelessWidget {
  const swipeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "swipe up to choose from specified folder",
      style: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 15.0,
      ),
    );
  }
}

class StatefulAlertDialog extends StatefulWidget {
  const StatefulAlertDialog({super.key});

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
                "Delete the main file",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched =
                        value; // Update the state variable when the switch is toggled.
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