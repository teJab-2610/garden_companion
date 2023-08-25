class MyUser {
  final String uid;
  final String username;
  final String name;
  final String password;
  final String email;
  final String phoneNumber;
  int followingCount;
  int followersCount;
  int postsCount;
  List<String> bookmarks;
  List<String> groups;
  String bio;

  MyUser({
    required this.uid,
    required this.username,
    required this.name,
    required this.password,
    required this.email,
    required this.phoneNumber,
    required this.followingCount,
    required this.followersCount,
    required this.postsCount,
    required this.bookmarks,
    required this.groups,
    required this.bio,
  });

  factory MyUser.fromJson(Map<String, dynamic> json, String uid) {
    // print(json['userId'] as String);
    // print(json['password'] as String);
    // print(json['followersCount'] as int);
    // print(json['email'] as String);
    // print(json['phoneNumber'] as String);
    // print(json['followingCount'] as int);

    // print('postsCount');
    // print(json['postsCount'] as int);
    //print(json['bookmarks'] as List<String>);
    return MyUser(
      uid: uid,
      username: json['userId'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      followingCount: json['followingCount'] as int,
      followersCount: json['followersCount'] as int,
      postsCount: json['postsCount'] as int,
      bookmarks: List<String>.from(json['bookmarks'] as List<dynamic>),
      groups: List<String>.from(json['groups'] as List<dynamic>),
      bio: json['bio'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'name': name,
      'password': password,
      'email': email,
      'phoneNumber': phoneNumber,
      'followingCount': followingCount,
      'followersCount': followersCount,
      'postsCount': postsCount,
      'bookmarks': bookmarks,
      'groups': groups,
      'bio': bio,
    };
  }
}
