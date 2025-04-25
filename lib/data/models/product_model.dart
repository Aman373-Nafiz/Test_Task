
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;
  final bool isFavorite;
  final double originalPrice;
  final int discount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
    this.isFavorite = false,
    required this.originalPrice,
    required this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {

    final currentPrice = json['price'].toDouble();
    final calculatedOriginalPrice = (currentPrice * 1.25).toDouble();
    final calculatedDiscount = ((calculatedOriginalPrice - currentPrice) / calculatedOriginalPrice * 100).round();

    return Product(
      id: json['id'],
      title: json['title'],
      price: currentPrice,
      description: json['description'],
      category: json['category'],
      image: json['image'],
      rating: json['rating']['rate'].toDouble(),
      ratingCount: json['rating']['count'],
      originalPrice: calculatedOriginalPrice,
      discount: calculatedDiscount,
    );
  }
}