// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/search_screen.dart';
 // Updated import path based on your error

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadProducts(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Search Anything...',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


            Expanded(
              child: productsState.isLoading && productsState.products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : productsState.error != null
                  ? Center(child: Text('Error: ${productsState.error}'))
                  : productsState.products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                      !productsState.isLoading &&
                      productsState.hasMore) {
                    ref.read(productsProvider.notifier).loadProducts();
                  }
                  return true;
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: productsState.products.length + (productsState.isLoading && productsState.hasMore ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index >= productsState.products.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ProductCard(product: productsState.products[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}