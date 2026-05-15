import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id']?.toString() ?? '',
        firstName: map['first_name'] as String? ?? map['firstName'] as String? ?? '',
        lastName: map['last_name'] as String? ?? map['lastName'] as String? ?? '',
        email: map['email'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

  @override
  List<Object> get props => [id, firstName, lastName, email];
}
