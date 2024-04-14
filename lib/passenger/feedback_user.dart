import 'package:flutter/material.dart';
import '../Model/FeedbackModel.dart';
import '../database/database_helper.dart'; // Adjust path as necessary
// import '../model/feedback_model.dart'; // Adjust path as necessary, ensure correct casing and naming

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _nameController = TextEditingController();
  final DbHelper _dbHelper = DbHelper();

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      // Create a new UserFeedback object
      UserFeedback feedback = UserFeedback(userName: _nameController.text, feedback: _feedbackController.text);

      // Insert the UserFeedback object into the database
      await _dbHelper.insertFeedback(feedback);

      // Clear the text fields
      _feedbackController.clear();
      _nameController.clear();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback submitted successfully'))
      );

      // Optionally, close the feedback screen
      // Navigator.pop(context); // Uncomment this line if you want to close the feedback screen upon submission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Submit Feedback"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  labelText: 'Feedback',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your feedback',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: Text('Submit Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
