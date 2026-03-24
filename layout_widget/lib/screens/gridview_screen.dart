import 'package:flutter/material.dart';
import 'package:layout_widget/models/product.dart';
import 'package:layout_widget/screens/detail_screen.dart';

class GridviewScreen extends StatefulWidget {
  const GridviewScreen({super.key});

  @override
  State<GridviewScreen> createState() => _GridviewScreenState();
}

class _GridviewScreenState extends State<GridviewScreen> {

  // 1. 위젯 그리드
  List<Widget> productWidgetList = 
    List.generate(10, (index) => Card(
      elevation: 4,       // Card 그림자 효과 크기
      child: GridTile(
        header: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.all(10.0), 
              child: Icon(Icons.more_vert),
            )
          ],
        ),
        footer: Column(
          children: [
            Text("상품 제목 ${index+1}"),
            Text("상품 설명 ${index+2}"),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Image.asset(
              "image/product${index+1}.webp",
              fit: BoxFit.cover,
            ),
          ),
        )
      ),
    ));

    // 2. 동적 상품 객체 리스트
    final List<Product> productList = 
      List.generate(10, (index) => Product(
        image: "image/product${index+1}.webp", 
        title: "상품 제목 ${index+1}", 
        description: "${index+1}번째 상품 설명입니다."
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("그리들 뷰"),),
      body: Container(
        child: Center(
          child: 
          //   GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 2,        // 열의 개수
          //     crossAxisSpacing: 10.0,   // 열 간격
          //     mainAxisSpacing: 10.0,    // 행 간격
          //   ),
          //   children: productWidgetList,
          // ),
          // 동적 그리드뷰
          GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 10.0, 
            mainAxisSpacing: 10.0
          ), 
            itemCount: productList.length, 
            itemBuilder: (context, index) {
              final product = productList[index]; 
              // 제스처 감지 : 이벤트 다양함
              return GestureDetector(
                onTap: () {
                  // print('클릭!');
                  // 상품 목록 화면 제거 - 뒤로가기버튼 사라짐
                  // 더이상 스크린이 쌓이지 않음
                  // Navigator.of(context).pop();
                  // 상세 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(product: product)
                    )
                  );
                },
                child: Card(
                  elevation: 4,
                  child: GridTile(
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(padding: EdgeInsets.all(10.0),
                          child: Icon(Icons.more_vert),
                        )
                      ],
                    ),
                    footer: Column(
                      children: [
                        Text(product.title ?? "상품 제목"),
                        Text(product.description ?? "상품 설명"),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: Image.asset(
                          product.image ?? "image/product.jpg",
                          fit:BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
            );
          },)
        ),
      ),
    );
  }
}