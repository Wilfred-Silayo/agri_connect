enum OrderStatus {
  pending('pending'),
  delivered('delivered'),
  confirmed('confirmed'),
  cancelled('cancelled');

  final String value;
  const OrderStatus(this.value);
}

extension ConvertStringToOrderStatus on String {
  OrderStatus toOrderStatusEnum() {
    switch (this) {
      case 'delivered':
        return OrderStatus.delivered;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
