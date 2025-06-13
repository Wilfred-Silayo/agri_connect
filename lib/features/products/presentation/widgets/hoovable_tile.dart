import 'package:agri_connect/core/enums/order_status_enum.dart';
import 'package:agri_connect/features/products/models/order_model.dart';
import 'package:agri_connect/features/products/presentation/pages/order_details_page.dart';
import 'package:flutter/material.dart';

class HoverableOrderTile extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onDelete;

  const HoverableOrderTile({super.key, required this.order, this.onDelete});

  @override
  State<HoverableOrderTile> createState() => _HoverableOrderTileState();
}

class _HoverableOrderTileState extends State<HoverableOrderTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDeletable =
        widget.order.status.value == OrderStatus.cancelled.value ||
        widget.order.status.value == OrderStatus.delivered.value;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(order: widget.order),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ]
                : [],
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${widget.order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${widget.order.totalAmount.toStringAsFixed(2)} TZS',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Status: ${widget.order.status.value}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              if (isDeletable && widget.onDelete != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete order',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
