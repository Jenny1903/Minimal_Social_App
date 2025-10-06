import '../models/user.dart';
import '../models/post.dart';

class SampleData {
static final User currentUser = User(
id: '1',
name: 'Sarah Johnson',
username: '@sarahj',
postsCount: 128,
followersCount: 1200,
followingCount: 345,
);

static final List<Post> posts = [
Post(
id: '1',
author: User(
id: '2',
name: 'Alex Chen',
username: '@alexc',
postsCount: 0,
followersCount: 0,
followingCount: 0,
),
content: 'Just finished an amazing hike! The view from the top was absolutely breathtaking. Nature never fails to inspire me 🌲',
type: PostType.text,
createdAt: DateTime.now().subtract(const Duration(hours: 2)),
likesCount: 24,
commentsCount: 8,
sharesCount: 3,
),
Post(
id: '2',
author: User(
id: '3',
name: 'Mike',
username: '@mike',
postsCount: 0,
followersCount: 0,
followingCount: 0,
),
content: 'Hi everyone! 👋',
type: PostType.text,
createdAt: DateTime.now().subtract(const Duration(hours: 1)),
likesCount: 12,
commentsCount: 4,
),
Post(
id: '3',
author: User(
id: '4',
name: 'Emma',
username: '@emma',
postsCount: 0,
followersCount: 0,
followingCount: 0,
),
content: '',
type: PostType.image,
imageUrl: 'sunset_photo',
createdAt: DateTime.now().subtract(const Duration(hours: 3)),
likesCount: 45,
commentsCount: 12,
),
Post(
id: '4',
author: User(
id: '5',
name: 'Lisa Wang',
username: '@lisaw',
postsCount: 0,
followersCount: 0,
followingCount: 0,
),
content: 'Perfect morning coffee at my favorite local spot ☕',
type: PostType.image,
imageUrl: 'coffee_shop',
createdAt: DateTime.now().subtract(const Duration(hours: 4)),
likesCount: 67,
commentsCount: 15,
sharesCount: 8,
),
Post(
id: '5',
author: User(
id: '6',
name: 'David Kim',
username: '@davidk',
postsCount: 0,
followersCount: 0,
followingCount: 0,
),
content: 'This quote has been my motivation throughout this week. What inspires you?',
type: PostType.quote,
quoteText: 'The best way to predict the future is to create it.',
quoteAuthor: 'Peter Drucker',
createdAt: DateTime.now().subtract(const Duration(hours: 6)),
likesCount: 89,
commentsCount: 23,
sharesCount: 12,
),
];
}