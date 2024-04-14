class PaymentModel {
  int? paymentId;
  String paymentMethod;
  String paymentDate;
  int relatedOrderId;

  PaymentModel({
    this.paymentId,
    required this.paymentMethod,
    required this.paymentDate,
    required this.relatedOrderId,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'paymentId': paymentId, // Normally not needed for insertion as it's auto-incremented
      'payment_method': paymentMethod,
      'payment_date': paymentDate,
      'related_order_id': relatedOrderId,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      paymentId: map['payment_id'],
      paymentMethod: map['payment_method'],
      paymentDate: map['payment_date'],
      relatedOrderId: map['related_order_id'],
    );
  }
}
