import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPickerPage extends StatefulWidget {
  const GalleryPickerPage({super.key});

  @override
  State<GalleryPickerPage> createState() => _GalleryPickerPageState();
}

class _GalleryPickerPageState extends State<GalleryPickerPage> {
  List<AssetEntity> _assets = [];         // 기기 갤러리에서 불러온 이미지 에셋 목록
  final Set<AssetEntity> _selected = {};  // 선택된 이미지 에셋 목록
  bool _loading = true;                   // 에셋 로딩 중
  bool _denied = false;                   // 갤러리 권한 거부
  
  @override
  void initState() {
    super.initState();
    _loadAssets();
  }
  /// 권한 확인 후 에셋을 불러온다. 권한 거부 시 [_denied]를 true로 설정한다.
  Future<void> _loadAssets() async {
    // permission_handler로 먼저 권한 확인 / 요청
    final bool granted = await _checkPermission();
    if (!granted) {
      setState(() {
        _denied = true;
        _loading = false;
      });
      return;
    }
    // photo_manager 내부 권한 검사 우회 (permission_handler가 이미 처리)
    PhotoManager.setIgnorePermissionCheck(true);
    await _loadAssetsInternal();
  }

  /// 플랫폼별 갤러리 접근 권한을 요청하고 허용 여부를 반환한다.
  /// - iOS: Photos 권한
  /// - Android 14+: READ_MEDIA_VISUAL_USER_SELECTED
  /// - Android 13: READ_MEDIA_IMAGES
  /// - Android 12 이하: READ_EXTERNAL_STORAGE
  Future<bool> _checkPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    }
    // Android 14+ : READ_MEDIA_VISUAL_USER_SELECTED (limited = 선택 사진)
    final visual = await Permission.photos.request();
    if (visual.isGranted || visual.isLimited) return true;
    // Android 13 : READ_MEDIA_IMAGES
    final images = Permission.mediaLibrary;
    final imgStatus = await images.request();
    if (imgStatus.isGranted) return true;
    // Android 12 이하 : READ_EXTERNAL_STORAGE
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  /// photo_manager로 전체 이미지 에셋을 최신순으로 불러와 [_assets]를 갱신한다.
  Future<void> _loadAssetsInternal() async {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
      ),
    );
    if (paths.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    // 모든 사진 앨범(첫 번째 경로 = 전체) 에서 가져오기
    final all = paths.first;
    final count = await all.assetCountAsync;
    final assets = await all.getAssetListRange(start: 0, end: count);
    setState(() {
      _assets = assets;
      _loading = false;
    });
  }

  /// [asset]의 선택 상태를 토글한다. 선택 순서는 [_selected] Set의 삽입 순서로 관리된다.
  void _toggle(AssetEntity asset) {
    setState(() {
      if (_selected.contains(asset)) _selected.remove(asset);
      else _selected.add(asset);
    });
  }

  /// 선택된 에셋 목록을 반환하며 페이지를 닫는다.
  void _confirm() => Navigator.pop(context, _selected.toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        title: Text(
          _selected.isEmpty ? '사진 선택' : '${_selected.length}장 선택됨',
        ),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty ? null : _confirm,
            child: Text(
              '추가',
              style: TextStyle(
                color: _selected.isEmpty ? Colors.white38 : Colors.blueAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _denied
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, size: 64, color: Colors.white38),
                    const SizedBox(height: 16),
                    const Text('갤러리 접근 권한이 없습니다.',
                        style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => PhotoManager.openSetting(),
                      child: const Text('설정 열기'),
                    ),
                  ],
                ),
              )
            : _assets.isEmpty
                ? const Center(
                    child: Text('사진이 없습니다.',
                        style: TextStyle(color: Colors.white54)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(2),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: _assets.length,
                    itemBuilder: (context, index) {
                      final asset = _assets[index];
                      final isSelected = _selected.contains(asset);
                      final selIndex = isSelected
                          ? _selected.toList().indexOf(asset) + 1
                          : -1;
                      return GestureDetector(
                        onTap: () => _toggle(asset),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 썸네일
                            _AssetThumbnail(asset: asset),
                            // 선택 오버레이
                            if (isSelected)
                              Container(color: Colors.blue.withValues(alpha: 0.35)),
                            // 선택 순서 뱃지
                            Positioned(
                              top: 6,
                              right: 6,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blueAccent
                                      : Colors.black45,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white70, width: 1.5),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Text(
                                          '$selIndex',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
    );
  }
}

class _AssetThumbnail extends StatefulWidget {
  final AssetEntity asset;  // 썸네일을 표시할 이미지 에셋
  const _AssetThumbnail({required this.asset});

  @override
  State<_AssetThumbnail> createState() => __AssetThumbnailState();
}

class __AssetThumbnailState extends State<_AssetThumbnail> {
  Uint8List? _data; // 비동기로 로드된 썸네일 바이트 데이터 (null이면 로딩 중)
  @override
  void initState() {
    super.initState();
    _load();
  }
  /// 300×300 크기의 썸네일 데이터를 비동기로 불러와 [_data]에 저장한다.
  Future<void> _load() async {
    final data = await widget.asset
        .thumbnailDataWithSize(const ThumbnailSize(300, 300));
    if (mounted) setState(() => _data = data);
  }
  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return Container(color: Colors.grey[800]);
    }
    return Image.memory(_data!, fit: BoxFit.cover);
  }
}