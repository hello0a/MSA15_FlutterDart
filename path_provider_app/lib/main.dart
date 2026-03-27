// input / output
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() {
  // SharedPrefences 공유 환경설정에 데이터 저장 예제
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: 
          const FileApp(),
    );
  }
}

class FileApp extends StatefulWidget {
  const FileApp({super.key});

  @override
  State<FileApp> createState() => _FileAppState();
}

class _FileAppState extends State<FileApp> {

  TextEditingController _controller = TextEditingController();
  List<String> itemList = [];

  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    List<String> savedItemList = await readListFile();
    setState(() {
      itemList = savedItemList;
    });
  }
  

  // 파일 데이터를 불러오는 함수
  // 📕 ➡ List
  Future<List<String>> readListFile() async {

    List<String> itemList = [];

    // 최초 파일 생성
    // - 처음 파일 생성 시, SharedPeferences 로 'frist' 라는 데이터를 확인
    var key = 'first';
    SharedPreferences pref = await SharedPreferences.getInstance();
    var firstCheck = pref.getBool(key);
    var dir = await getApplicationDocumentsDirectory();
    var file;
    bool fileExist = await File(dir.path + '/test.txt').exists();

    // 최초인 경우 
    // 1. null  2. false  
    if( firstCheck == null || firstCheck == false || fileExist == false ) {
      pref.setBool(key, true);

      // 최초 파일 생성
      // - 프로젝트 안의 파일 가져오기
      file = await DefaultAssetBundle.of(context).loadString('repo/test.txt');
      // - 가져온 파일로 스마트폰에 저장하기
      File(dir.path + '/test.txt').writeAsStringSync(file);
    } else {

      // 파일 읽기
      // File(파일경로)
      file = await File(dir.path + '/test.txt').readAsString();
    }

    var array = file.split('\n');   // \n (엔터)
    for (var item in array) {
      itemList.add(item);
    }

    return itemList;
  }

  // 파일 데이터를 저장하는 함수
  void writeListFile(String data) async {
    // 파일 가져오기
    var dir = await getApplicationDocumentsDirectory();   // path provider
    var file = await File(dir.path + '/test.txt').readAsString(); // readAsString 입력
    // 기존 파일에 새 데이터 추가
    file = file + '\n' + data;
    // 파일 저장
    File(dir.path + '/test.txt').writeAsStringSync(file); // writeAsStringSync 출력
  }

  // 파일 데이터를 갱신하는 함수
  Future<bool> deleteListFile(int index) async {
    // itemList 에서 index 에 해당하는 데이터 삭제
    List<String> copyList = [];
    copyList.addAll(itemList);
    copyList.removeAt(index);

    // copyList 의 데이터들을 '\n' 로 구분하여 문자열로 변환
    var fileData = "";
    for (var item in copyList) {
      fileData += item + "\n";
    }
    // 파일 저장
    try {
      var dir = await getApplicationDocumentsDirectory();
      File(dir.path + '/test.txt').writeAsStringSync(fileData);
    } catch (e) {
      print(e);
      return false;
    }

    return true;
  }

  bool value = false;

  Future<bool> _getFuture() async {
      await Future.delayed(const Duration(seconds: 2));
      return !value;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('카드 메모 앱'),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: toggleTheme, 
              icon: const Icon(Icons.brightness_2_outlined)
            ),
          ] 
        ),
        body: Container(
          child: Center(
            child: Column(
              children: [
                // TextFied : controller, keyboardType
                
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          onSubmitted: (data) {
                            print(data);
                            writeListFile(data);
                            setState(() {
                              itemList.add(data);
                            });
                            _controller.text = '';
                          },
                          decoration: InputDecoration(
                            hintText: "메모를 입력해주세요",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )
                          ),
                        ),
                ),
                const SizedBox(height: 20.0),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return 
                          GestureDetector(
                            onLongPress: () async {
                              // 길게 누른 카드 삭제
                              bool check = await deleteListFile(index);
                              if( check ) {
                                setState(() {
                                  itemList.removeAt(index);
                                });
                              }
                            },
                            child: Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  margin: EdgeInsets.all(5),
                                  child: Padding(padding: const EdgeInsetsGeometry.all(10),
                                    child: Center(
                                      child: Text(
                                        itemList[index],
                                        style: TextStyle(
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          );
                    },
                    itemCount: itemList.length,
                  )
                ),
              ],
            )
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            writeListFile(_controller.text);
            setState(() {
              itemList.add(_controller.text);
            });
            _controller.text = '';
          },
          child: Icon(Icons.create),
        ),
      ),
    );
  }
}