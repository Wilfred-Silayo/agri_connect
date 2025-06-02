enum UserType {
  farmer('farmer'),
  buyer('buyer'),
  farmerAndBuyer('farmer and buyer');

  final String type;

  const UserType(this.type);
}

extension ConvertStringToUserType on String {
  UserType toUserTypeEnum() {
    switch (this) {
      case 'buyer':
        return UserType.buyer;
      case 'farmer and buyer':
        return UserType.farmerAndBuyer;
      default:
        return UserType.farmer;
    }
  }
}
