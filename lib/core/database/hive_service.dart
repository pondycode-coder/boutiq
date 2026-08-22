import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';
import 'models/order.dart';
import 'models/client.dart';
import 'models/cash_payment.dart';
import 'models/user.dart';
import 'models/store.dart';
import 'models/vendor.dart';

class HiveService {
  static Box<User> get usersBox => Hive.box<User>('users');

  static Box<Product> get productsBox => Hive.box<Product>('products');

  static Box<Order> get ordersBox => Hive.box<Order>('orders');

  static Box<OrderItem> get orderItemsBox => Hive.box<OrderItem>('order_items');

  static Box<CashPayment> get cashPaymentsBox =>
      Hive.box<CashPayment>('cash_payments');

  static Box<Client> get clientsBox => Hive.box<Client>('clients');

  static Box<Store> get storesBox => Hive.box<Store>('stores');

  static Box<Vendor> get vendorsBox => Hive.box<Vendor>('vendors');

  static Future<void> initialize({String? directory}) async {
    if (directory != null) {
      Hive.init(directory);
    } else {
      await Hive.initFlutter();
    }

    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(OrderAdapter());
    Hive.registerAdapter(OrderItemAdapter());
    Hive.registerAdapter(ClientAdapter());
    Hive.registerAdapter(CashPaymentAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(StoreAdapter());
    Hive.registerAdapter(VendorAdapter());

    await Hive.openBox<Product>('products');
    await Hive.openBox<Order>('orders');
    await Hive.openBox<OrderItem>('order_items');
    await Hive.openBox<Client>('clients');
    await Hive.openBox<CashPayment>('cash_payments');
    await Hive.openBox<User>('users');
    await Hive.openBox<Store>('stores');
    await Hive.openBox<Vendor>('vendors');
  }
}