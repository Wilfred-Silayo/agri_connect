import 'package:agri_connect/core/enums/order_status_enum.dart';
import 'package:agri_connect/core/enums/user_enums.dart';
import 'package:agri_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:agri_connect/features/products/models/order_model.dart';
import 'package:agri_connect/features/products/presentation/providers/order_provider.dart';
import 'package:agri_connect/features/products/presentation/widgets/hoovable_order_items_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailsPage extends ConsumerWidget {
  final OrderModel order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: authAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Not logged in"));
          }

          final userDetailsAsync = ref.watch(userDetailsProvider(user.id));

          return userDetailsAsync.when(
            data: (userModel) {
              if (userModel == null) {
                return const Center(child: Text("User details not found"));
              }

              final role = userModel.userType;
              final asyncItems = ref.watch(orderItemsProvider(order.id));

              return asyncItems.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('No items in this order.'));
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final asyncStatus = ref.watch(
                        orderItemStatusProvider(item.id),
                      );

                      return asyncStatus.when(
                        data: (status) {
                          final orderStatus = status.toOrderStatusEnum();
                          final isFarmer =
                              role == 'farmer'.toUserTypeEnum() ||
                              role == 'farmer and buyer'.toUserTypeEnum();
                          final isBuyer =
                              role == 'buyer'.toUserTypeEnum() ||
                              role == 'farmer and buyer'.toUserTypeEnum();

                          final itemBelongsToUser = item.sellerId == user.id;

                          final noneConfirmed = items.every(
                            (element) =>
                                element.status.value !=
                                OrderStatus.confirmed.value,
                          );

                          final allConfirmed = items.every(
                            (element) =>
                                element.status.value ==
                                OrderStatus.confirmed.value,
                          );

                          return Column(
                            children: [
                              HoverableOrderItemTile(
                                item: item.copyWith(status: orderStatus),
                                onConfirm:
                                    isFarmer &&
                                            itemBelongsToUser &&
                                            (orderStatus !=
                                                    OrderStatus.delivered ||
                                                orderStatus !=
                                                    OrderStatus.cancelled)
                                        ? () async {
                                          await ref
                                              .read(
                                                orderNotifierProvider.notifier,
                                              )
                                              .updateOrderItemStatus(
                                                orderId: order.id,
                                                itemId: item.id,
                                                newStatus:
                                                    OrderStatus.confirmed.value,
                                                columnToUpdate: 'confirmed_at',
                                              );
                                          ref.invalidate(
                                            orderItemsProvider(order.id),
                                          );
                                        }
                                        : null,
                                onCancel:
                                    isBuyer &&
                                            noneConfirmed &&
                                            orderStatus == OrderStatus.pending
                                        ? () async {
                                          await ref
                                              .read(
                                                orderNotifierProvider.notifier,
                                              )
                                              .updateOrderItemStatus(
                                                orderId: order.id,
                                                itemId: item.id,
                                                newStatus:
                                                    OrderStatus.cancelled.value,
                                                columnToUpdate: null,
                                              );
                                          ref.invalidate(
                                            orderItemsProvider(order.id),
                                          );
                                        }
                                        : null,
                                onDeliver:
                                    isBuyer &&
                                            orderStatus ==
                                                OrderStatus.confirmed &&
                                            allConfirmed
                                        ? () async {
                                          await ref
                                              .read(
                                                orderNotifierProvider.notifier,
                                              )
                                              .updateOrderItemStatus(
                                                orderId: order.id,
                                                itemId: item.id,
                                                newStatus:
                                                    OrderStatus.delivered.value,
                                                columnToUpdate: 'delivered_at',
                                              );
                                          ref.invalidate(
                                            orderItemsProvider(order.id),
                                          );
                                        }
                                        : null,
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox(),
                        error:
                            (e, _) => Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('Error loading status: $e'),
                            ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Failed to load user: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Auth error: $e')),
      ),
    );
  }
}
