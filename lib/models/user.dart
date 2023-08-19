
class MyUser {
  final String username;
  final String password;
  final String email;
  final String phoneNumber;
  final int followingCount;
  final int followersCount;
  final int postsCount;

  MyUser({
    required this.username,
    required this.password,
    required this.email,
    required this.phoneNumber,
    required this.followingCount,
    required this.followersCount,
    required this.postsCount,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
      username: json['username'],
      password: json['password'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      followingCount: json['followingCount'],
      followersCount: json['followersCount'],
      postsCount: json['postsCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'phoneNumber': phoneNumber,
      'followingCount': followingCount,
      'followersCount': followersCount,
      'postsCount': postsCount,
    };
  }
}
