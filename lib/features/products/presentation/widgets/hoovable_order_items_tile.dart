import 'package:agri_connect/features/products/models/order_items_model.dart';
import 'package:flutter/material.dart';

class HoverableOrderItemTile extends StatefulWidget {
  final OrderItemModel item;
  final VoidCallback? onConfirm;

  const HoverableOrderItemTile({
    super.key,
    required this.item,
    this.onConfirm,
  });

  @override
  State<HoverableOrderItemTile> createState() => _HoverableOrderItemTileState();
}

class _HoverableOrderItemTileState extends State<HoverableOrderItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered
              ? [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))]
              : [],
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item name : ${widget.item.stockName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text('Quantity: ${widget.item.quantity}'),
            Text('Price per unit: ${widget.item.price.toStringAsFixed(2)} TZS'),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${widget.item.status.value}',
                  style: TextStyle(
                    color: widget.item.status.value == 'confirmed' ? Colors.green : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.item.status.value != 'confirmed' && widget.onConfirm != null)
                  ElevatedButton(
                    onPressed: widget.onConfirm,
                    child: const Text('Confirm'),
                  )
                else if (widget.item.status.value == 'confirmed')
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
