import 'dart:core';

class User {
  final String name;
  final String email;

  User(this.name, this.email);

  User.fromJson(Map<String, dynamic> jsonMap)
      : name = jsonMap['name'],
        email = jsonMap['email'];
}