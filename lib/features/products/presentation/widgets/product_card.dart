import 'package:agri_connect/features/products/presentation/widgets/add_to_cart_button.dart';
import 'package:agri_connect/features/products/presentation/widgets/custom_tool_tip.dart';
import 'package:agri_connect/features/products/presentation/widgets/stock_image_carousel.dart';
import 'package:flutter/material.dart';
import 'package:agri_connect/features/products/models/stock_model.dart';

class ProductCard extends StatelessWidget {
  final StockModel stock;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.stock,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Navigate to details if needed
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            if (stock.images != null && stock.images!.isNotEmpty)
              StockImageCarousel(images: stock.images!, stockId: stock.id)
            else
              Container(
                height: 200,
                alignment: Alignment.center,
                color: Colors.grey[200],
                child: const Text('No image available'),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stock.description?.isNotEmpty == true
                        ? stock.description!
                        : 'No description available',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Available Qty: ${stock.quantity}'),
                      ),
                      const Spacer(),
                      Text(
                        'Tsh ${stock.price.toStringAsFixed(0)}/Qty',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  onAddToCart != null
                      ? AddToCartButton(onPressed: onAddToCart!)
                      : CustomToolTip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
