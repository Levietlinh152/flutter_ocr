import 'dart:io';
import 'package:flutter/material.dart';
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
  bool isPickedPhoto = false;
  AssetPathEntity? selectedAlbum;
  List<AssetEntity>? _galleryAssets;

  @override
  void initState() {
    super.initState();
    const QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'action_one') {
        getFirstPicture();
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

  Future<void> openGallery() async {
    final ImagePicker picker = ImagePicker();
    pickedPhoto = await picker.pickImage(source: ImageSource.gallery);

    if (pickedPhoto != null) {
      setState(() {
        isPickedPhoto = true;
        pickedPhotoPath = pickedPhoto?.path;
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
        child: Text('result'));
  }

  Widget _listFuntionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(),
              onPressed: () {},
              child: const Text(
                'Cancel',
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
              onPressed: () => (),
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
