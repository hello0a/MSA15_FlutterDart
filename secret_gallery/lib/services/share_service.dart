import 'package:share_plus/share_plus.dart';

class ShareService {

  // 여러 이미지 공유
  Future<void> sharePhoto(String imagePath) async {
    // 이전 버전 (deprecated)
    // await Share.shareXFiles([XFile(imagePath)]);

    // 최신 버전
    final params = ShareParams(
      files: [XFile(imagePath)],
      text: '이미지를 공유합니다.'
    );
    await SharePlus.instance.share( params );
  }
  
}