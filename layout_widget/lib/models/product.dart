// 상품 객체
class Product {
  String? image;        // 상품 이미지
  String? title;        // 상품 이름
  String? description;  // 상품 설명
  int? price;           // 상품 가격

  // 생성자
  Product(
    // required : 객체 생성 시, 필수로 전달해야하는 값으로 지정
    {
      required this.image,
      required this.title,
      this.description,
      this.price
    }
  );
}