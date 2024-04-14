import 'package:flutter/material.dart';
import '../Database/database_helper.dart';
import '../Model/UserModel.dart';

class ListUsers extends StatefulWidget {
  @override
  _ListUsersState createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  late DbHelper _dbHelper;
  late List<UserModel> _users;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dbHelper = DbHelper();
    _users = [];
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      List<UserModel> users = await _dbHelper.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(int userId) async {
    await _dbHelper.deleteUser(userId.toString());
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        backgroundColor: Colors.orange[600],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : _buildUserList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to add a new user, navigate to the user creation screen
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange[800],
      ),
    );
  }

  Widget _buildUserList() {
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return _users.isEmpty
        ? Center(child: Text('No users found.', style: TextStyle(fontSize: 16)))
        : ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(user.user_name),
            subtitle: Text(user.email),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(user.user_id!),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User?'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteUser(userId);
                Navigator.of(context). pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
