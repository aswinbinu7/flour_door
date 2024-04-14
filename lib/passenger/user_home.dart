import 'package:flour_door/passenger/user_profile.dart';
import 'package:flour_door/passenger/view_food_details.dart';
import 'package:flutter/material.dart';

import '../login/login_screen.dart';
import '../manage_food/list_users.dart';
import 'order_food_user.dart';

class UserHomeScreen extends StatelessWidget {
  final List<FunctionalityItem> functionalityItems = [
    FunctionalityItem(
      title: 'Product Details',
      icon: Icons.fastfood,
      onPressed: () => FoodDetailsScreen(), // Placeholder for actual implementation
    ),
    FunctionalityItem(
      title: 'Order History',
      icon: Icons.history,
      onPressed: () => OrderHistoryScreen(), // Placeholder for actual implementation
    ),
    FunctionalityItem(
      title: 'Profile',
      icon: Icons.person,
      onPressed: () => UserProfileScreen(), // Placeholder for actual implementation
    ),
  ];

  // Utility method to get a dynamic greeting based on the time of day
  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    String greeting = getGreeting();  // Get the dynamic greeting
    return Scaffold(
      appBar: AppBar(
        title: Text('$greeting, User'),  // Use the greeting in the AppBar
        backgroundColor: Colors.orange,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemCount: functionalityItems.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => functionalityItems[index].onPressed()),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        functionalityItems[index].icon,
                        size: 50,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(
                        functionalityItems[index].title,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FunctionalityItem {
  final String title;
  final IconData icon;
  final Widget Function() onPressed;

  FunctionalityItem({
    required this.title,
    required this.icon,
    required this.onPressed,
  });
}


