import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:flutter/material.dart';

class StockDetailPage extends StatelessWidget {
  final StockModel stock;
  const StockDetailPage({super.key, required this.stock});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(stock.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (stock.images != null && stock.images!.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView(
                  children:
                      stock.images!.map((imageUrl) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        );
                      }).toList(),
                ),
              ),
            const SizedBox(height: 20),
            Text('Name: ${stock.name}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Description: ${stock.description ?? "No description"}'),
            const SizedBox(height: 8),
            Text('Price: Tsh ${stock.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Quantity: ${stock.quantity}'),
          ],
        ),
      ),
    );
  }
}
