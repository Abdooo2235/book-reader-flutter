class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String password;
 
  final String? profilePicture;

  UserModel({
    this.profilePicture,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
   
  });
}

