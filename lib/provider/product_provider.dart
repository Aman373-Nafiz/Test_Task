
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product_model.dart';

import '../service/product_service.dart';



final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Product state
class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;

  ProductsState({
    required this.products,
    required this.isLoading,
    this.error,
    required this.page,
    required this.hasMore,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory ProductsState.initial() {
    return ProductsState(
      products: [],
      isLoading: false,
      error: null,
      page: 1,
      hasMore: true,
    );
  }
}

class ProductsNotifier extends Notifier<ProductsState> {
  late final ProductService _productService;

  @override
  ProductsState build() {
    _productService = ref.watch(productServiceProvider);
    loadProducts();
    return ProductsState.initial();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading || (!state.hasMore && !refresh)) return;

    state = state.copyWith(isLoading: true);

    try {
      final currentPage = refresh ? 1 : state.page;
      final limit = 10;

      final newProducts = await _productService.getProducts(
        limit: limit,

      );

      final updatedProducts = refresh
          ? newProducts
          : [...state.products, ...newProducts];

      state = state.copyWith(
        products: updatedProducts,
        isLoading: false,
        page: currentPage + 1,
        hasMore: newProducts.length == limit,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }



  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      loadProducts(refresh: true);
      return;
    }


    state = state.copyWith(isLoading: true);

    try {
      final products = await _productService.searchProducts(query);

      state = state.copyWith(
        products: products,
        isLoading: false,
        page: 1,
        hasMore: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),

      );
    }
  }
  void toggleFavorite(int productId) {
    final updatedProducts = state.products.map((product) {
      if (product.id == productId) {
        return Product(
          id: product.id,
          title: product.title,
          price: product.price,
          description: product.description,
          category: product.category,
          image: product.image,
          rating: product.rating,
          ratingCount: product.ratingCount,
          isFavorite: !product.isFavorite,
          originalPrice: product.originalPrice,
          discount: product.discount,
        );
      }
      return product;
    }).toList();

    state = state.copyWith(products: updatedProducts);
  }

  void sortProducts(SortOption option) {
    final products = [...state.products];

    switch (option) {
      case SortOption.priceLowToHigh:
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.none:
      default:
        break;
    }

    state = state.copyWith(products: products);
  }
}

enum SortOption { none, priceLowToHigh, priceHighToLow, rating }


final productsProvider = NotifierProvider<ProductsNotifier, ProductsState>(() {
  return ProductsNotifier();
});


final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.none);


final searchQueryProvider = StateProvider<String>((ref) => '');