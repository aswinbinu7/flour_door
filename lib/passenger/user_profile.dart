import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/UserModel.dart';
import '../Database/database_helper.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late DbHelper _dbHelper;
  UserModel? _currentUser;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper = DbHelper();
    _fetchCurrentUserDetails();
  }

  Future<void> _fetchCurrentUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId != null) {
      UserModel? user = await _dbHelper.getUserById(userId);
      if (user != null) {
        setState(() {
          _currentUser = user;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
      ),
      body: _currentUser == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                'Name',
                style: TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                _currentUser!.user_name,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text(
                'Email',
                style: TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                _currentUser!.email,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showEditUserDialog(),
              icon: Icon(Icons.edit),
              label: Text('Edit Details'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showChangePasswordDialog(),
              icon: Icon(Icons.lock),
              label: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditUserDialog() async {
    TextEditingController nameController = TextEditingController(text: _currentUser!.user_name);
    TextEditingController emailController = TextEditingController(text: _currentUser!.email);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                _currentUser!.user_name = nameController.text;
                _currentUser!.email = emailController.text;
                await _dbHelper.updateUser(_currentUser!);
                Navigator.pop(context);
                _fetchCurrentUserDetails();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Old Password'),
              ),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_newPasswordController.text != _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
                  return;
                }
                if (_currentUser!.password != _oldPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Incorrect old password')));
                  return;
                }

                _currentUser!.password = _newPasswordController.text;
                await _dbHelper.updateUser(_currentUser!);
                Navigator.pop(context);
                _oldPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
