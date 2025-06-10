class AccountModel {
  final String id;
  final String userId;
  final double balance;
  final DateTime createdAt;

  AccountModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.createdAt,
  });

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      userId: map['user_id'],
      balance: (map['balance'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AccountModel copyWith({double? balance}) {
    return AccountModel(
      id: id,
      userId: userId,
      balance: balance ?? this.balance,
      createdAt: createdAt,
    );
  }
}
