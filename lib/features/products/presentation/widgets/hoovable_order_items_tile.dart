import 'package:agri_connect/features/products/models/order_items_model.dart';
import 'package:flutter/material.dart';

class HoverableOrderItemTile extends StatefulWidget {
  final OrderItemModel item;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onDeliver;

  const HoverableOrderItemTile({
    super.key,
    required this.item,
    this.onConfirm,
    this.onCancel,
    this.onDeliver,
  });

  @override
  State<HoverableOrderItemTile> createState() => _HoverableOrderItemTileState();
}

class _HoverableOrderItemTileState extends State<HoverableOrderItemTile> {
  bool _isHovered = false;

  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirmed,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.item.status.value;

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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: $status',
                  style: TextStyle(
                    color: status == 'confirmed' ? Colors.green : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    if (status != 'confirmed' && widget.onConfirm != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () => _showConfirmationDialog(
                            title: 'Confirm Order Item',
                            content: 'Are you sure you want to confirm this item?',
                            onConfirmed: widget.onConfirm!,
                          ),
                          child: const Text('Confirm'),
                        ),
                      ),
                    if (status != 'cancelled' && widget.onCancel != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: OutlinedButton(
                          onPressed: () => _showConfirmationDialog(
                            title: 'Cancel Order Item',
                            content: 'Are you sure you want to cancel this item?',
                            onConfirmed: widget.onCancel!,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    if (status == 'confirmed' && widget.onDeliver != null)
                      ElevatedButton(
                        onPressed: () => _showConfirmationDialog(
                          title: 'Deliver Order Item',
                          content: 'Are you sure this item has been delivered?',
                          onConfirmed: widget.onDeliver!,
                        ),
                        child: const Text('Deliver'),
                      ),
                    if (status == 'confirmed')
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.check_circle, color: Colors.green),
                      ),
                    if (status == 'cancelled')
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.cancel, color: Colors.red),
                      ),
                    if (status == 'delivered')
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.local_shipping, color: Colors.blue),
                      ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
