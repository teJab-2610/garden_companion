class MyUser {
  final String username;
  final String password;
  final String email;
  final String phoneNumber;
  final int followingCount;
  final int followersCount;
  final int postsCount;

  MyUser(
      {required this.username,
      required this.password,
      required this.email,
      required this.phoneNumber,
      required this.followingCount,
      required this.followersCount,
      required this.postsCount});
}
