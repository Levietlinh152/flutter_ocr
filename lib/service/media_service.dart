
import 'package:photo_manager/photo_manager.dart';

class MediaServices {
  Future loadAlbums() async {
    var permission = await PhotoManager.requestPermissionExtend();
    List<AssetPathEntity> albumList = [];

    if (permission.isAuth == true) {
      albumList = await PhotoManager.getAssetPathList(
         onlyAll: true,
      );
    } else {
      PhotoManager.openSetting();
    }

    return albumList;
  }

  Future loadAssets(AssetPathEntity selectedAlbum) async {
    List<AssetEntity> assetList = await selectedAlbum.getAssetListRange(
      start: 0,
      // ignore: deprecated_member_use
      end: selectedAlbum.assetCount,
    );
    return assetList;
  }
}
