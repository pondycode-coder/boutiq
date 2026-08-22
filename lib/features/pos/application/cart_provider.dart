import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/cameroon_config.dart';
import '../../../core/database/models/product.dart';

class CartItem {
  CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  int quantity;

  double get lineSubtotal => product.price * quantity;

  double get lineVatAmount => lineSubtotal * CameroonConfig.vatRate;

  double get lineTotal => lineSubtotal + lineVatAmount;
}

final cartNotifierProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(Product product, {int quantity = 1}) {
    final existingIndex =
        state.indexWhere((item) => item.product.productId == product.productId);
    if (existingIndex >= 0) {
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == existingIndex)
            CartItem(
              product: state[i].product,
              quantity: state[i].quantity + quantity,
            )
          else
            state[i],
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
  }

  void increment(String productId) {
    state = [
      for (final item in state)
        if (item.product.productId == productId)
          CartItem(product: item.product, quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void decrement(String productId) {
    state = [
      for (final item in state)
        if (item.product.productId == productId)
          CartItem(product: item.product, quantity: item.quantity - 1)
        else
          item,
    ];
    state = state.where((item) => item.quantity > 0).toList();
  }

  void removeItem(String productId) {
    state = [
      for (final item in state)
        if (item.product.productId != productId) item,
    ];
  }

  void clear() => state = [];

  double get subtotal => state.fold(0, (sum, item) => sum + item.lineSubtotal);

  double get vatAmount => state.fold(0, (sum, item) => sum + item.lineVatAmount);

  double get total => subtotal + vatAmount;

  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
}