import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../Model/FeedbackModel.dart';
import '../database/database_helper.dart';
import '../login/login_screen.dart';
import 'booking.dart';
import 'feedback_user.dart';
import 'order_food_user.dart';
import 'user_profile.dart';
import 'view_food_details.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  List<UserFeedback> feedbackList = [];

  @override
  void initState() {
    super.initState();
    loadFeedbacks();
  }

  void loadFeedbacks() async {
    var dbHelper = DbHelper();
    List<UserFeedback> fetchedFeedbacks = await dbHelper.getFeedbacks();
    setState(() {
      feedbackList = fetchedFeedbacks.reversed.toList(); // Reverse the list to show newest on top
    });
  }


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
    String greeting = getGreeting();
    return Scaffold(
      appBar: AppBar(
        title: Text('$greeting'),
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
          child: Column(
            children: [
              buildFunctionalityGrid(),
              SizedBox(height: 20),
              buildFeedbackSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFunctionalityGrid() {
    return GridView.builder(
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
    );
  }

  Widget buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Feedbacks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: feedbackList.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    getInitials(feedbackList[index].userName),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  feedbackList[index].userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(feedbackList[index].feedback),
                trailing: IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: () {}, // Placeholder for like functionality
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String getInitials(String name) => name.isNotEmpty
      ? name.trim().split(' ').map((l) => l[0]).take(2).join()
      : '';



  final List<FunctionalityItem> functionalityItems = [
    FunctionalityItem(
      title: 'Product Details',
      icon: Icons.fastfood,
      onPressed: () => FoodDetailsScreen(),
    ),
    FunctionalityItem(
      title: 'Order History',
      icon: Icons.history,
      onPressed: () => OrderHistoryScreen(),
    ),
    FunctionalityItem(
      title: 'Profile',
      icon: Icons.person,
      onPressed: () => UserProfileScreen(),
    ),
    FunctionalityItem(
      title: 'Feedback',
      icon: Icons.feedback,
      onPressed: () => FeedbackScreen(),
    ),
    FunctionalityItem(
      title: 'Booking',
      icon: Icons.feedback,
      onPressed: () => ViewTimeSlotsScreen(),
    ),
  ];
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
