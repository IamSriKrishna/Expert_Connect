class TransactionSummary {
  final bool success;
  final Summary summary;

  TransactionSummary({
    required this.success,
    required this.summary,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    return TransactionSummary(
      success: json['success'] as bool,
      summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }

  // Factory initial for empty/default instance
  factory TransactionSummary.initial() {
    return TransactionSummary(
      success: false,
      summary: Summary.initial(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'summary': summary.toJson(),
    };
  }
}

class Summary {
  final int totalCredit;
  final int totalDebit;
  final int currentBalance;

  Summary({
    required this.totalCredit,
    required this.totalDebit,
    required this.currentBalance,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalCredit: json['total_credit'] as int,
      totalDebit: json['total_debit'] as int,
      currentBalance: json['current_balance'] as int,
    );
  }

  // Factory initial for empty/default instance
  factory Summary.initial() {
    return Summary(
      totalCredit: 0,
      totalDebit: 0,
      currentBalance: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_credit': totalCredit,
      'total_debit': totalDebit,
      'current_balance': currentBalance,
    };
  }
}