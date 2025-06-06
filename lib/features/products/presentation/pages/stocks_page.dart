import 'package:agri_connect/core/shared/widgets/error_display.dart';
import 'package:agri_connect/core/shared/widgets/loader.dart';
import 'package:agri_connect/core/shared/widgets/show_loading_dialog.dart';
import 'package:agri_connect/core/shared/widgets/show_snackbar.dart';
import 'package:agri_connect/core/utils/stock_query.dart';
import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:agri_connect/features/products/presentation/pages/stock_details_page.dart';
import 'package:agri_connect/features/products/presentation/providers/stock_provider.dart';
import 'package:agri_connect/features/products/presentation/providers/stock_state.dart';
import 'package:agri_connect/features/products/presentation/widgets/add_stock.dart';
import 'package:agri_connect/features/products/presentation/widgets/stock_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StocksPage extends ConsumerStatefulWidget {
  final String userId;
  const StocksPage({super.key, required this.userId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StocksPageState();
}

class _StocksPageState extends ConsumerState<StocksPage> {
  @override
  Widget build(BuildContext context) {
    final stockAsyncValue = ref.watch(fetchStockProvider(const StockQuery()));

    ref.listen<StockState>(stockNotifierProvider, (previous, next) {
      if (next is StockLoading) {
        showLoadingDialog(context, message: next.message);
      } else {
        hideLoadingDialog(context);
      }

      if (next is StockFailure) {
        showSnackBar(context, next.message);
      } else if (next is StockSuccess) {
        showSnackBar(context, next.message);
        ref.invalidate(fetchStockProvider(const StockQuery()));
        Navigator.pop(context, true);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stocks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddStockBottomSheet(context),
          ),
        ],
      ),
      body: stockAsyncValue.when(
        data: (stocks) {
          if (stocks == null || stocks.isEmpty) {
            return const Center(child: Text('No stocks available.'));
          }
          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return StockCard(
                stock: stock,
                onEdit: (s) => _showEditStockBottomSheet(context, s),
                onDelete: (s) => _confirmDelete(context, s),
                onView: (s) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StockDetailPage(stock: s),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Loader(),
        error: (error, _) => ErrorDisplay(error: error),
      ),
    );
  }

  void _showAddStockBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => AddStockForm(
            userId: widget.userId,
            onSubmit: (stock, images) {
              ref
                  .read(stockNotifierProvider.notifier)
                  .createStock(stock, images);
            },
          ),
    );
  }

  void _showEditStockBottomSheet(BuildContext context, StockModel stock) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => AddStockForm(
            stockToEdit: stock,
            userId: widget.userId,
            onSubmit: (updatedStock, images) {
               ref.read(stockNotifierProvider.notifier).updateStock(stock.id, updatedStock, images);
            },
          ),
    );
  }

  void _confirmDelete(BuildContext context, StockModel stock) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Stock'),
            content: const Text('Are you sure you want to delete this stock?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      ref.read(stockNotifierProvider.notifier).deleteStock(stock.id);
    }
  }
}
