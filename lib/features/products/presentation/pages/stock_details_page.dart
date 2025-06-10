import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:agri_connect/features/products/presentation/widgets/add_to_cart_button.dart';
import 'package:agri_connect/features/products/presentation/widgets/stock_image_carousel.dart';
import 'package:flutter/material.dart';

class StockDetailPage extends StatefulWidget {
  final StockModel stock;
  final VoidCallback? onAddToCart;
  const StockDetailPage({super.key, required this.stock, this.onAddToCart});

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
          if (widget.onAddToCart != null)
            AddToCartButton(onPressed: widget.onAddToCart!),
        ],
      ),
    );
  }
}
