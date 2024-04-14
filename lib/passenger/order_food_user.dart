import 'package:flutter/material.dart';
import '../Database/database_helper.dart';
import '../Model/OrderModel.dart';
import '../Model/FoodModel.dart';
import 'transcation_page.dart';  // Make sure the path is correct

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late List<OrderModel> _orders;
  late DbHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DbHelper();
    _orders = [];
    _fetchOrders();
  }

  void _fetchOrders() async {
    List<OrderModel> orders = await _dbHelper.getAllOrders();
    setState(() {
      _orders = orders;
    });
  }

  void _deleteOrder(int? orderId) async {
    if (orderId != null) {
      await _dbHelper.deleteOrder(orderId);
      _fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order History',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            SizedBox(height: 20.0),
            if (_orders.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No orders yet.',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    OrderModel order = _orders[index];
                    return Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        title: Text(
                          'Order ID: ${order.orderId}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Product Details'),
                                _buildFoodDetails(order),
                                _buildSectionTitle('Customer Details'),
                                _buildPassengerDetails(order),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    _buildCancelButton(order),
                                    _buildPaymentButton(order),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.orange[800],
        ),
      ),
    );
  }

  Widget _buildFoodDetails(OrderModel order) {
    return FutureBuilder<FoodModel?>(
      future: _dbHelper.getFoodById(order.orderFoodId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Text("Unable to fetch data.");
        } else {
          FoodModel food = snapshot.data!;
          double totalItemPrice = food.price * order.quantity;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Name: ${food.food_name}',
                style: TextStyle(fontSize: 14.0),
              ),
              Text(
                'Price per Item: \$${food.price}',
                style: TextStyle(fontSize: 14.0),
              ),
              Text(
                'Quantity: ${order.quantity}',
                style: TextStyle(fontSize: 14.0),
              ),
              Text(
                'Total Price: \$${totalItemPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14.0),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPassengerDetails(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name: ${order.fullName}',
          style: TextStyle(fontSize: 14.0),
        ),
        Text(
          'Email Address: ${order.emailAddress}',
          style: TextStyle(fontSize: 14.0),
        ),
        Text(
          'Contact Number: ${order.contactNumber}',
          style: TextStyle(fontSize: 14.0),
        ),
        Text(
          'Address: ${order.address}',
          style: TextStyle(fontSize: 14.0),
        ),
      ],
    );
  }

  Widget _buildCancelButton(OrderModel order) {
    return TextButton(
      onPressed: () => _confirmCancel(context, order),
      child: Text(
        'Cancel Order',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  void _confirmCancel(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Order'),
          content: Text('Are you sure you want to cancel this order?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                _deleteOrder(order.orderId);
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentButton(OrderModel order) {
    return FutureBuilder<FoodModel?>(
      future: _dbHelper.getFoodById(order.orderFoodId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError || snapshot.data == null) {
          return Text("Unable to fetch data");
        } else {
          FoodModel food = snapshot.data!;
          return ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionPage(order: order, food: food),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Pay'),
          );
        }
      },
    );
  }
}
