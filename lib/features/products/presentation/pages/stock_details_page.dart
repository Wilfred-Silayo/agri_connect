import 'package:agri_connect/features/auth/presentation/pages/profile_page.dart';
import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:agri_connect/features/products/presentation/widgets/add_to_cart_button.dart';
import 'package:agri_connect/features/products/presentation/widgets/custom_tool_tip.dart';
import 'package:agri_connect/features/products/presentation/widgets/stock_image_carousel.dart';
import 'package:flutter/material.dart';

class StockDetailPage extends StatefulWidget {
  final StockModel stock;
  final bool? isProduct;
  final VoidCallback? onAddToCart;
  const StockDetailPage({
    super.key,
    required this.stock,
    this.onAddToCart,
    this.isProduct,
  });

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  @override
  Widget build(BuildContext context) {
    final stock = widget.stock;

    return Scaffold(
      appBar: AppBar(
        title: Text(stock.name),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (stock.images != null && stock.images!.isNotEmpty)
            StockImageCarousel(images: stock.images!, stockId: stock.id)
          else
            Container(
              height: 200,
              alignment: Alignment.center,
              color: Colors.grey[200],
              child: const Text('No image available'),
            ),
          const SizedBox(height: 24),
          // Contant
          buildContactButton(),
          const SizedBox(height: 8),
          Text(
            stock.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stock.description ?? 'No description available',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Price per Qty:', style: TextStyle(fontSize: 16)),
              Text(
                'Tsh ${stock.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Available Quantity:', style: TextStyle(fontSize: 16)),
              Text(
                stock.quantity.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          buildActionButton(),
        ],
      ),
    );
  }

  Widget buildActionButton() {
    final isProduct = widget.isProduct;
    final onAddToCart = widget.onAddToCart;
    if (isProduct == null && onAddToCart == null) {
      return const SizedBox();
    }

    if (isProduct == true && onAddToCart != null) {
      return AddToCartButton(onPressed: onAddToCart);
    }

    return CustomToolTip();
  }

  Widget buildContactButton() {
    final isProduct = widget.isProduct;
    final onAddToCart = widget.onAddToCart;
    if (isProduct == null && onAddToCart == null) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Chip
                Align(
                  alignment: Alignment.centerRight,
                  child: ActionChip(
                    label: const Text('Contact'),
                    avatar: const Icon(Icons.person, size: 20),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => ProfilePage(userId: widget.stock.userId),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
