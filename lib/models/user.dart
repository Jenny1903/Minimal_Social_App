class User {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  User ({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    this.isFollowing = false,
});
}
