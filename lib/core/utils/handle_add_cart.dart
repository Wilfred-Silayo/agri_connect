import 'package:agri_connect/core/shared/widgets/show_snackbar.dart';
import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:agri_connect/features/products/presentation/pages/stock_details_page.dart';
import 'package:agri_connect/features/products/presentation/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void handleAddToCart(
  BuildContext context,
  WidgetRef ref,
  StockModel stock, {
  bool pushDetail = false,
}) {
  final cartItems = ref.read(cartProvider);

  if (pushDetail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => StockDetailPage(
              stock: stock,
              isProduct: true,
              onAddToCart: () => handleAddToCart(context, ref, stock),
            ),
      ),
    );
  } else {
    final isInCart = cartItems.keys.any((item) => item.id == stock.id);

    if (isInCart) {
      showSnackBar(context, 'Item is already in the cart');
    } else {
      ref.read(cartProvider.notifier).addToCart(stock);
      showSnackBar(context, 'Added to cart');
    }
  }
}
