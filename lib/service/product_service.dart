import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/product_model.dart';


class ProductService {
  final String baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> getProducts({int limit = 10, int offset = 0}) async {

    final response = await http.get(
      Uri.parse('$baseUrl/products?limit=$limit'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Product>> getAllProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    // Get all products and filter on client side since FakeStore API
    // doesn't have search endpoint
    final products = await getAllProducts();

    return products.where((product) =>
        product.title.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}