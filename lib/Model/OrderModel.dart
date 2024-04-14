class OrderModel {
  int? orderId;
  int? orderUserId;
  int? orderFoodId;
  int quantity;
  String orderTime;
  String? fullName;
  String? emailAddress;
  int? contactNumber; // Changed to integer
  String? address;

  OrderModel({
    this.orderId,
    this.orderUserId,
    this.orderFoodId,
    required this.quantity,
    required this.orderTime,
    this.fullName,
    this.emailAddress,
    this.contactNumber,
    this.address,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['order_id'],
      orderUserId: map['order_user_id'],
      orderFoodId: map['order_food_id'],
      quantity: map['quantity'],
      orderTime: map['order_time'],
      fullName: map['full_name'],
      emailAddress: map['email_address'],
      contactNumber: map['contact_number'],
      address: map['address'],

    );
  }

  Map<String, dynamic> toMap() {
    var map = {
      'order_user_id': orderUserId,
      'order_food_id': orderFoodId,
      'quantity': quantity,
      'order_time': orderTime,
      'full_name': fullName,
      'email_address': emailAddress,
      'contact_number': contactNumber,
      'address': address,
    };
    if (orderId != null) {
      map['order_id'] = orderId;
    }
    return map;
  }
}
