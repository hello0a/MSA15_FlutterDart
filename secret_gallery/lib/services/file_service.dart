import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileService {
  // 이미지 경로 가져오기
  Future<String> _getImageDir() async {
    final dir = await getApplicationCacheDirectory();
    final imageDir = Directory('${dir.path}/images');

    if ( !imageDir.existsSync() ) {
      imageDir.createSync();
    }

    return imageDir.path;
  }

  // 이미지 저장
  Future<String> saveImage(String sourcePath) async {
    final dir = await _getImageDir();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final newPath = '$dir/$fileName.png';

    await File(sourcePath).copy(newPath);

    return newPath;
  }

  // 이미지 삭제
  Future<void> deleteImage(String path) async {
    final file = File(path);
    if ( file.existsSync() ) {
      await file.delete();
    }
  }
}