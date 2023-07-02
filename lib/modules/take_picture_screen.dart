import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ocr/models/image_information.dart';
import 'package:flutter_siri_suggestions/flutter_siri_suggestions.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:quick_actions/quick_actions.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key});

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  String? pickedPhotoPath;
  XFile? pickedPhoto;
  List<AssetEntity>? _galleryAssets;
  String? resultText;
  var listInformation = [];
  @override
  void initState() {
    super.initState();
    initSuggestions(); // addd short cut for ios
    //
    const QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) async {
      if (shortcutType == 'action_one') {
        cancelProcess();
        await getFirstPicture();
        await processImage(pickedPhotoPath);
      }
    });
    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_one',
        localizedTitle: 'Take a picture',
        icon: 'add_photo',
      ),
    ]);
    // _requestAssets();
  }

  void initSuggestions() async {
    FlutterSiriSuggestions.instance.configure(
        onLaunch: (Map<String, dynamic> message) async {
      debugPrint('[FlutterSiriSuggestions] [onLaunch] $message');
      setState(() async {
        cancelProcess();
        await getFirstPicture();
        await processImage(pickedPhotoPath);
      });
    });

    await FlutterSiriSuggestions.instance.registerActivity(
        const FlutterSiriActivity("Process First Image", "mainActivity",
            isEligibleForSearch: true,
            isEligibleForPrediction: true,
            contentDescription: "Process First Image",
            suggestedInvocationPhrase: "open my app",
            userInfo: {"info": "sample"}));
  }

  Future<void> getFirstPicture() async {
    PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(onlyAll: true);
      if (albums.isNotEmpty) {
        _galleryAssets = await albums[0].getAssetListPaged(
          page: 0,
          size: 1,
        );
        if (_galleryAssets!.isNotEmpty) {
          String firstImagePath = (await _galleryAssets![0].file)!.path;
          print('First image path: $firstImagePath');
          setState(() {
            pickedPhotoPath = firstImagePath;
          });
        }
      }
    } else {
      print('Permission denied');
    }
  }

  Future<void> processImage(String? imgPath) async {
    if (imgPath != null) {
      if (listInformation.isEmpty) {
        // Recognized Text
        final textRecognizer =
            TextRecognizer(script: TextRecognitionScript.latin);
        var image = InputImage.fromFile(File(imgPath));
        RecognizedText recognizedText =
            await textRecognizer.processImage(image);
        // create json
        for (TextBlock block in recognizedText.blocks) {
          for (int i = 0; i < block.lines.length; i++) {
            String _text = block.lines[i].text;
            int _x = block.lines[i].cornerPoints[0].x;
            int _y = block.lines[i].cornerPoints[0].y;
            //
            listInformation.add(ImageInformation(x: _x, y: _y, text: _text).toJson());
          }
        }
        setState(() {
          resultText = listInformation.toString();
        });
         await Clipboard.setData(ClipboardData(text: listInformation.toString())).then((_) => 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(listInformation.isEmpty ? 'Cant detect this Image' : 'Export json successful'),
      )));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please choose a image"),
      ));
    }
  }

  Future<void> cancelProcess() async {
    setState(() {
      pickedPhotoPath = null;
      resultText = '';
      listInformation = [];
    });
  }

  Future<void> openGallery() async {
    final ImagePicker picker = ImagePicker();
    pickedPhoto = await picker.pickImage(source: ImageSource.gallery);

    if (pickedPhoto != null) {
      setState(() {
        pickedPhotoPath = pickedPhoto?.path;
        listInformation = [];
        resultText = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            _getPicture(),
            _showPicture(),
            _result(),
            _listFuntionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _getPicture() {
    return GestureDetector(
      onTap: openGallery,
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        decoration: BoxDecoration(
          border: Border.all(width: 3.0),
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        ),
        width: MediaQuery.of(context).size.width,
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Select your picture'),
              Icon(Icons.add),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showPicture() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
          padding: const EdgeInsets.only(top: 20),
          child: pickedPhotoPath != null
              ? Image.file(File(pickedPhotoPath!))
              : const SizedBox()),
    );
  }

  Widget _result() {
    return Container(
        padding: const EdgeInsets.only(top: 10),
        width: MediaQuery.of(context).size.width,
        child: Text(resultText ?? ''));
  }

  Widget _listFuntionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(),
              onPressed: () => cancelProcess(),
              child: const Text(
                'Clear',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(),
              onPressed: () => processImage(pickedPhotoPath),
              child: const Text(
                'Run',
                style: TextStyle(fontSize: 14),
              ),
            ),
          )
        ],
      ),
    );
  }
}
