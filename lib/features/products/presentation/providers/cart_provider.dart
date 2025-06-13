import 'package:agri_connect/features/products/models/stock_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<StockModel, int>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Map<StockModel, int>> {
  CartNotifier() : super({});

  void addToCart(StockModel item) {
    final alreadyInCart = state.keys.any((i) => i.id == item.id);
    if (!alreadyInCart) {
      state = {...state, item: 1}; // default quantity is 1
    }
  }

  void removeFromCart(String stockId) {
    state = Map.from(state)..removeWhere((key, _) => key.id == stockId);
  }

  void increment(String stockId) {
    final entry = state.entries.firstWhere((e) => e.key.id == stockId);
    final stock = entry.key;
    final quantity = entry.value;

    if (quantity < stock.quantity) {
      state = {
        for (final e in state.entries)
          if (e.key.id == stockId)
            e.key: quantity + 1
          else
            e.key: e.value
      };
    }
  }

  void decrement(String stockId) {
    final entry = state.entries.firstWhere((e) => e.key.id == stockId);
    final quantity = entry.value;

    if (quantity > 1) {
      state = {
        for (final e in state.entries)
          if (e.key.id == stockId)
            e.key: quantity - 1
          else
            e.key: e.value
      };
    }
  }

  void clearCart() {
    state = {};
  }
}




