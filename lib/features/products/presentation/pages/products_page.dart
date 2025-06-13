import 'package:agri_connect/core/enums/user_enums.dart';
import 'package:agri_connect/core/shared/widgets/drawer.dart';
import 'package:agri_connect/core/utils/handle_add_cart.dart';
import 'package:agri_connect/core/utils/stock_query.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/messages/presentation/pages/messages.dart';
import 'package:agri_connect/features/products/presentation/pages/cart_page.dart';
import 'package:agri_connect/features/products/presentation/providers/cart_provider.dart';
import 'package:agri_connect/features/products/presentation/providers/category_provider.dart';
import 'package:agri_connect/features/products/presentation/providers/stock_provider.dart';
import 'package:agri_connect/features/products/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final cartItems = ref.watch(cartProvider);

    final authStateAsync = ref.watch(authStateProvider);

    final stockQuery = StockQuery(
      id: selectedCategory,
      query: searchQuery.trim().isEmpty ? null : searchQuery,
    );

    final products = ref.watch(fetchStockProvider(stockQuery));
    final categoryAsync = ref.watch(categoryStreamProvider);

    return authStateAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) =>
              Scaffold(body: Center(child: Text('Error loading auth state'))),
      data: (authUser) {
        final userId = authUser?.id;
        if (userId == null) {
          return const Scaffold(body: Center(child: Text('Please log in.')));
        }

        final userDetailsAsync = ref.watch(userDetailsProvider(userId));

        return userDetailsAsync.when(
          loading:
              () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
          error:
              (e, _) =>
                  Scaffold(body: Center(child: Text(e.toString()))),
          data: (user) {
            final isFarmer = user?.userType == UserType.farmer;

            return Scaffold(
              drawer: CustomDrawer(),
              appBar: AppBar(
                title: const Text('Marketplace'),
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        tooltip: 'Cart',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartPage(),
                            ),
                          );
                        },
                      ),
                      if (cartItems.isNotEmpty)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${cartItems.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.message_outlined),
                    tooltip: 'Messages',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MessagesPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Search Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged:
                          (value) =>
                              ref.read(searchQueryProvider.notifier).state =
                                  value,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Category Filter
                  categoryAsync.when(
                    data:
                        (categories) => SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length + 1,
                            itemBuilder: (_, index) {
                              if (index == 0) {
                                final isSelected = selectedCategory == null;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: ChoiceChip(
                                    label: const Text('All'),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      ref
                                          .read(
                                            selectedCategoryProvider.notifier,
                                          )
                                          .state = null;
                                    },
                                  ),
                                );
                              }

                              final category = categories[index - 1];
                              final isSelected =
                                  category.id.toString() == selectedCategory;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: ChoiceChip(
                                  label: Text(category.name),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    ref
                                        .read(selectedCategoryProvider.notifier)
                                        .state = isSelected
                                            ? null
                                            : category.id.toString();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error loading categories'),
                  ),

                  const SizedBox(height: 8),

                  // Product List
                  Expanded(
                    child: products.when(
                      data: (stocks) {
                        if (stocks == null || stocks.isEmpty) {
                          return const Center(
                            child: Text('No products found.'),
                          );
                        }
                        return ListView.builder(
                          itemCount: stocks.length,
                          itemBuilder: (context, index) {
                            final stock = stocks[index];
                            return ProductCard(
                              stock: stock,
                              onTap: () {
                                handleAddToCart(
                                  context,
                                  ref,
                                  stock,
                                  pushDetail: true,
                                  isFarmer: isFarmer
                                );
                              },
                              onAddToCart:
                                  isFarmer
                                      ? null
                                      : () =>
                                          handleAddToCart(context, ref, stock),
                            );
                          },
                        );
                      },
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
