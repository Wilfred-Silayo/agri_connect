import 'package:agri_connect/core/shared/widgets/error_display.dart';
import 'package:agri_connect/core/shared/widgets/loader.dart';
import 'package:agri_connect/core/shared/widgets/show_loading_dialog.dart';
import 'package:agri_connect/core/shared/widgets/show_snackbar.dart';
import 'package:agri_connect/features/account/presentation/providers/account_provider.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:agri_connect/features/products/presentation/providers/cart_provider.dart';
import 'package:agri_connect/features/products/presentation/providers/order_provider.dart';
import 'package:agri_connect/features/products/presentation/providers/order_state.dart';
import 'package:agri_connect/features/products/presentation/widgets/stock_image_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  void onCheckout({
    required String buyerId,
    required Map<StockModel, int> cart,
  }) async {
    final currentUserAccount = await ref
        .read(accountProvider.notifier)
        .getAccountById(buyerId);

    await ref
        .read(orderNotifierProvider.notifier)
        .placeOrderWithBalanceCheck(
          buyerId: buyerId,
          cart: cart,
          balance: currentUserAccount.balance,
          ref: ref,
        );

    ref.invalidate(cartProvider);
    ref.invalidate(userAccountProvider(buyerId));
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    final total = cart.entries.fold<double>(
      0,
      (sum, entry) => sum + (entry.key.price * entry.value),
    );

    final currentUser = ref.watch(authStateProvider);

    ref.listen<OrderState>(orderNotifierProvider, (previous, next) {
      if (next is OrderLoading) {
        showLoadingDialog(context, message: 'Processing an order...');
      } else {
        hideLoadingDialog(context);
      }

      if (next is OrderFailure) {
        showSnackBar(context, next.message);
        print('error: ${next.message}');
      } else if (next is OrderSuccess) {
        showSnackBar(context, "Order placed Successfully!");
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Shopping Cart")),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const SizedBox();
          }

          final accountAsync = ref.watch(userAccountProvider(user.id));

          return accountAsync.when(
            data: (account) {
              final balance = account.balance;

              return Column(
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Balance :', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 5),
                              Text(
                                '${balance.toStringAsFixed(2)} TZS',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child:
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
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (item.images != null &&
                                            item.images!.isNotEmpty)
                                          StockImageCarousel(
                                            images: item.images!,
                                            stockId: item.id,
                                          )
                                        else
                                          Container(
                                            height: 200,
                                            alignment: Alignment.center,
                                            color: Colors.grey[200],
                                            child: const Text(
                                              'No image available',
                                            ),
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
                                          item.description ??
                                              'No description available',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.remove_circle,
                                                  ),
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                          cartProvider.notifier,
                                                        )
                                                        .decrement(item.id);
                                                  },
                                                ),
                                                Text('$quantity'),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.add_circle,
                                                  ),
                                                  onPressed:
                                                      quantity < item.quantity
                                                          ? () {
                                                            ref
                                                                .read(
                                                                  cartProvider
                                                                      .notifier,
                                                                )
                                                                .increment(
                                                                  item.id,
                                                                );
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
                  ),
                  if (cart.isNotEmpty)
                    BottomAppBar(
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
                              onPressed: () async {
                                onCheckout(buyerId: user.id, cart: cart);
                              },
                              icon: const Icon(
                                Icons.payment,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Checkout",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
            error: (err, st) => ErrorDisplay(error: err),
            loading: () => const Loader(),
          );
        },
        error: (err, st) => ErrorDisplay(error: err),
        loading: () => const Loader(),
      ),
    );
  }
}
