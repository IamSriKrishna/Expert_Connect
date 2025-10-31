class TransactionResponse {
  final bool success;
  final List<Transaction> transactions;

  TransactionResponse({required this.success, required this.transactions});

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'] as bool? ?? false,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory TransactionResponse.initial() {
    return TransactionResponse(success: false, transactions: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }
}

class Transaction {
  final int id;
  final int userId;
  final int appointmentId;
  final int amount;
  final int balanceAfter;
  final String type;
  final String remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.appointmentId,
    required this.amount,
    required this.balanceAfter,
    required this.type,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      appointmentId: json['appointment_id'] as int? ?? 0,
      amount: json['amount'] as int? ?? 0,
      balanceAfter: json['balance_after'] as int? ?? 0,
      // ✅ Handle null values with proper defaults
      type: json['type'] as String? ?? '',
      remarks: json['remarks'] as String? ?? '',
      // ✅ Handle null dates safely
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  factory Transaction.initial() {
    return Transaction(
      id: 0,
      userId: 0,
      appointmentId: 0,
      amount: 0,
      balanceAfter: 0,
      type: '',
      remarks: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'appointment_id': appointmentId,
      'amount': amount,
      'balance_after': balanceAfter,
      'type': type,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}