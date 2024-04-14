import 'package:flutter/material.dart';
import '../Database/database_helper.dart';
import '../Model/FeedbackModel.dart';
import '../login/login_screen.dart';
import 'list_users.dart';
import '../food/manage_food_screen.dart';
import 'orders_screen.dart';

class SelectFunctionalityScreen extends StatefulWidget {
  @override
  _SelectFunctionalityScreenState createState() => _SelectFunctionalityScreenState();
}

class _SelectFunctionalityScreenState extends State<SelectFunctionalityScreen> {
  late Future<List<UserFeedback>> _feedbacks;

  @override
  void initState() {
    super.initState();
    _feedbacks = DbHelper().getFeedbacks();  // Assumes DbHelper has this method
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flour Door'),
        backgroundColor: Colors.orange,
      ),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, Let's Begin",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 20),
              buildFunctionalityList(),
              SizedBox(height: 20),
              buildFeedbackSection(),  // Display feedbacks section
            ],
          ),
        ),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.logout, color: Colors.orange),
                SizedBox(width: 10),
                Text('LOGOUT', style: TextStyle(color: Colors.orange)),
              ],
            ),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildFunctionalityList() {
    final functionalityItems = [
      FunctionalityItem(
        title: 'ORDERS',
        icon: Icons.shopping_cart,
        color: Colors.black,
        onPressed: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrdersScreen()),
          );
        },
      ),
      FunctionalityItem(
        title: 'MANAGE PRODUCT',
        icon: Icons.food_bank,
        color: Colors.black,
        onPressed: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodDetailsPage()),
          );
        },
      ),
      FunctionalityItem(
        title: 'LIST USERS',
        icon: Icons.list_alt,
        color: Colors.black,
        onPressed: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListUsers()),
          );
        },
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: functionalityItems.map((item) => ListTile(
          leading: Icon(item.icon, color: item.color),
          title: Text(item.title, style: TextStyle(color: Colors.black)),
          onTap: () => item.onPressed(context),
        )).toList(),
      ),
    );
  }

  Widget buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedbacks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        SizedBox(height: 10),
        FutureBuilder<List<UserFeedback>>(
          future: _feedbacks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  UserFeedback feedback = snapshot.data![index];
                  return Card(
                    color: Colors.orange[50],
                    child: ListTile(
                      leading: Icon(Icons.feedback, color: Colors.orange),
                      title: Text(feedback.userName),
                      subtitle: Text(feedback.feedback),
                    ),
                  );
                },
              );
            } else {
              return Text("No feedbacks found.");
            }
          },
        ),
      ],
    );
  }
}

class FunctionalityItem {
  final String title;
  final IconData icon;
  final Color color;
  final Function(BuildContext context) onPressed;

  FunctionalityItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}
