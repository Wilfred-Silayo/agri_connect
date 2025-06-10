import 'package:agri_connect/features/products/presentation/providers/cart_provider.dart';
import 'package:agri_connect/features/products/presentation/widgets/stock_image_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    final total = cart.entries.fold<double>(
      0,
      (sum, entry) => sum + (entry.key.price * entry.value),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Shopping Cart")),
      body:
          cart.isEmpty
              ? const Center(child: Text("Your cart is empty"))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final entry = cart.entries.elementAt(index);
                  final item = entry.key;
                  final quantity = entry.value;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Carousel with dots
                          if (item.images != null && item.images!.isNotEmpty)
                            StockImageCarousel(
                              images: item.images!,
                              stockId: item.id,
                            )
                          else
                            Container(
                              height: 200,
                              alignment: Alignment.center,
                              color: Colors.grey[200],
                              child: const Text('No image available'),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description ?? 'No description available',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Price per Qty:"),
                              Text(
                                "Tsh ${item.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Available Quantity:"),
                              Text(
                                item.quantity.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: () {
                                      ref
                                          .read(cartProvider.notifier)
                                          .decrement(item.id);
                                    },
                                  ),
                                  Text('$quantity'),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed:
                                        quantity < item.quantity
                                            ? () {
                                              ref
                                                  .read(cartProvider.notifier)
                                                  .increment(item.id);
                                            }
                                            : null,
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .removeFromCart(item.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar:
          cart.isNotEmpty
              ? BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: Tsh ${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Proceed to checkout logic
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text("Checkout"),
                      ),
                    ],
                  ),
                ),
              )
              : null,
    );
  }
}
