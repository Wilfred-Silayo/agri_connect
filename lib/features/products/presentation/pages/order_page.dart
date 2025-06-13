import 'package:agri_connect/core/enums/order_status_enum.dart';
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
  late final TabController _mainTabController;
  OrderStatus _selectedStatus = OrderStatus.pending;

  final mainTabs = ['My Orders', 'External Orders'];
  final orderStatuses = OrderStatus.values;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: mainTabs.length, vsync: this);
  }

  void _onStatusSelected(OrderStatus status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _mainTabController,
          tabs: mainTabs.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children:
                  orderStatuses.map((status) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(status.value),
                        selected: _selectedStatus == status,
                        onSelected: (_) => _onStatusSelected(status),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                // My Orders: as buyer
                OrderListTab(
                  userId: user.id,
                  status: _selectedStatus.value,
                  isExternal: false,
                ),
                // External Orders: as farmer
                OrderListTab(
                  userId: user.id,
                  status: _selectedStatus.value,
                  isExternal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
