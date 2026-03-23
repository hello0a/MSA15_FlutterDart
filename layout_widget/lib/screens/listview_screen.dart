// stfl
import 'package:flutter/material.dart';
import 'package:layout_widget/models/product.dart';

class ListviewScreen extends StatefulWidget {
  const ListviewScreen({super.key});

  @override
  State<ListviewScreen> createState() => _ListviewScreenState();
}

class _ListviewScreenState extends State<ListviewScreen> {

  // 1. 상품 객체 위젯 리스트
  final List<Widget> productWidgetList = 
    List.generate(10, (index) => ListTile(
      leading: const Icon(Icons.label),
      title: Text("상품 제목 ${index+1}"),
      subtitle: Text("상품 설명 ${index+1} 입니다"),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        // 아이템 클릭 시 동작
      },
    ));

  // 2. 상품 객체 리스트
  // 1) yaml assets: -image/ 추가
  // 2) get Package 클릭
  // 3) 다시 시작 클릭
  final List<Product> productList = 
    List.generate(10, (index) => Product(
      image: "image/product${index+1}.webp",
      title: "상품 제목 ${index+1}",
      description: "상품 설명 ${index+1}입니다",
      price: 10000
    )
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("리스트 뷰"),),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
        child: Center(
          child:
            // 기본 ListView 위젯
            // ListView(
            //   children: productWidgetList,
            // )
            ListView.builder(
              itemCount: productList.length, 
              itemBuilder: (context, index) {
                final product = productList[index];
                return ListTile(
                  leading: Image.asset(product.image ?? "image/product.jpg"),
                  title: Text(product.title ?? "상품제목"),
                  subtitle:
                    Row(children: [
                      Text('${product.price ?? 0}원 | '),
                      SizedBox(width: 10,),
                      Text(product.description ?? "설명"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    print('아이템 클릭');
                  },
                );
              }
            )
        ),
      ),
    );
  }
}