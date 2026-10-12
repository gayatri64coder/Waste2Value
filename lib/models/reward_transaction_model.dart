/// RewardTransaction model tracking points earned and redeemed
class RewardTransaction {
  final String id;
  final String userId;
  final String rewardId;
  final String title;
  final int pointsChange; // Positive for earned, negative for redeemed
  final String transactionType; // 'earn', 'redeem'
  final String? voucherCode;
  final DateTime timestamp;
  final String status;

  const RewardTransaction({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.title,
    required this.pointsChange,
    required this.transactionType,
    this.voucherCode,
    required this.timestamp,
    this.status = 'completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'rewardId': rewardId,
      'title': title,
      'pointsChange': pointsChange,
      'transactionType': transactionType,
      'voucherCode': voucherCode,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  factory RewardTransaction.fromMap(Map<String, dynamic> map, String id) {
    return RewardTransaction(
      id: id,
      userId: map['userId'] as String? ?? 'user_default',
      rewardId: map['rewardId'] as String? ?? 'reward_default',
      title: map['title'] as String? ?? 'Transaction',
      pointsChange: (map['pointsChange'] as num?)?.toInt() ?? 0,
      transactionType: map['transactionType'] as String? ?? 'redeem',
      voucherCode: map['voucherCode'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] as String? ?? 'completed',
    );
  }
}
