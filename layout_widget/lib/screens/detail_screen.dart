import 'package:flutter/material.dart';
import 'package:layout_widget/models/product.dart';

class DetailScreen extends StatelessWidget {

  // 상품 객체 선언
  final Product product;
  // 생성자에 상품 이름 매개변수 추가
  const DetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("상세 화면"),
      ),
      body: Container(
        margin: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 450,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(product.image ?? "image/product.jpg"),
                  fit: BoxFit.cover
                ),
                borderRadius: BorderRadius.circular(20.0)
              ),
            ),
            const SizedBox(height: 12.0,),
            Text(
              product.title ?? "상품 이름",
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 12.0,),
            Text(
              product.description ?? "상품 설명입니다.",
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 10.0,),
            Text(
              "${product.price}원",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.red
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10.0,
              children: [
                Expanded(child: 
                  ElevatedButton(
                    onPressed: () {}, 
                    child: Text("장바구니")
                  ),
                ),
                Expanded(child: 
                  ElevatedButton(
                    onPressed: () {}, 
                    child: Text("주문하기")
                  )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}