
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stylus/widgets/product_card.dart';
import '../provider/product_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadProducts(refresh: true);
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
    ref.read(productsProvider.notifier).searchProducts(_searchController.text);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(productsProvider.notifier).searchProducts('');
  }

  void _showSortBottomSheet() {
    final currentSortOption = ref.read(sortOptionProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildSortOptionsSheet(currentSortOption);
      },
    );
  }

  Widget _buildSortOptionsSheet(SortOption currentOption) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildSortOption(
            'Price - High to Low',
            SortOption.priceHighToLow,
            currentOption,
          ),
          const Divider(),
          buildSortOption(
            'Price - Low to High',
            SortOption.priceLowToHigh,
            currentOption,
          ),
          const Divider(),
          buildSortOption(
            'Rating',
            SortOption.rating,
            currentOption,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildSortOption(String title, SortOption option, SortOption currentOption) {
    return InkWell(
      onTap: () {
        ref.read(sortOptionProvider.notifier).state = option;
        ref.read(productsProvider.notifier).sortProducts(option);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: currentOption == option ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final hasSearchText = _searchController.text.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
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
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              decoration: const InputDecoration(
                                hintText: 'Search Anything...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              autofocus: true,
                              onChanged: (value) {
                                // Force rebuild to show/hide clear button
                                setState(() {});
                              },
                            ),
                          ),
                          if (hasSearchText)
                            GestureDetector(
                              onTap: _clearSearch,
                              child: const Icon(Icons.clear, size: 20, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showSortBottomSheet,
                  ),
                ],
              ),
            ),


            Expanded(
              child: productsState.isLoading && productsState.products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : productsState.error != null
                  ? Center(child: Text('Error: ${productsState.error}'))
                  : productsState.products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: productsState.products.length + (productsState.isLoading ? 2 : 0),
                itemBuilder: (context, index) {
                  if (index >= productsState.products.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ProductCard(product: productsState.products[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}