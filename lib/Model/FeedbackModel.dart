class UserFeedback {
  int? id;
  String userName;
  String feedback;

  UserFeedback({this.id, required this.userName, required this.feedback});

  Map<String, dynamic> toMap() {
    return {
      'feedback_id': id, // Match the column name
      'user_name': userName, // Correct the column name
      'user_feedback': feedback, // Correct the column name
    };
  }

  factory UserFeedback.fromMap(Map<String, dynamic> map) {
    return UserFeedback(
      id: map['feedback_id'], // Match the column name
      userName: map['user_name'], // Correct the column name
      feedback: map['user_feedback'], // Correct the column name
    );
  }
}
