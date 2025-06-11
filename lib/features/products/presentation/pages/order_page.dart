import 'package:agri_connect/core/enums/order_status_enum.dart';
import 'package:agri_connect/core/enums/user_enums.dart';
import 'package:agri_connect/features/auth/models/user_model.dart';
import 'package:agri_connect/features/products/presentation/widgets/order_list_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderPage extends ConsumerStatefulWidget {
  final UserModel user;
  const OrderPage({super.key, required this.user});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final orderStatuses = OrderStatus.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: orderStatuses.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    // Only show orders if user is farmer or farmer & buyer
    if (user.userType != UserType.buyer &&
        user.userType != UserType.farmerAndBuyer) {
      return Scaffold(
        appBar: AppBar(title: const Text('Orders')),
        body: const Center(
          child: Text('Only available for buyers or farmer-buyers'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: orderStatuses.map((status) => Tab(text: status.value)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: orderStatuses.map<Widget>((status) {
          return OrderListTab(userId: user.id, status: status.value);
        }).toList(),
      ),
    );
  }
}
