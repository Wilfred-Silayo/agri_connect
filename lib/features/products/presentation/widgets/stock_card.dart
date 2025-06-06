import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class StockCard extends StatelessWidget {
  final StockModel stock;
  final void Function(StockModel)? onEdit;
  final void Function(StockModel)? onDelete;
  final void Function(StockModel)? onView;

  const StockCard({
    super.key,
    required this.stock,
    this.onEdit,
    this.onDelete,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 100, // Increase height here
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              stock.images != null && stock.images!.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 1.0,
                          height: 80,
                        ),
                        items:
                            stock.images!.map((imageUrl) {
                              return Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: 80,
                              );
                            }).toList(),
                      ),
                    ),
                  )
                  : const Icon(Icons.inventory_2_outlined, size: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stock.description?.isNotEmpty == true
                          ? stock.description!
                          : 'No description',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Qty: ${stock.quantity}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Tsh ${stock.price.toStringAsFixed(2)}/Qty',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'view') {
                        onView?.call(stock);
                      } else if (value == 'edit') {
                        onEdit?.call(stock);
                      } else if (value == 'delete') {
                        onDelete?.call(stock);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('View Details'),
                          ),
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                        ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
