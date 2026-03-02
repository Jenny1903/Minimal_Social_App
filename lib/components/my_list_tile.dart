import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/auth_provider.dart';
import 'package:social_app/providers/posts_provider.dart';
import 'package:social_app/components/who_liked_sheet.dart';

class MyListTile extends ConsumerStatefulWidget {
  final String postId;
  final String title;
  final String username;
  final String? profilePicture;
  final List<String>? imageUrls;
  final Timestamp? timestamp;
  final int likeCount;
  final int commentCount;
  final VoidCallback? onCommentTap;

  const MyListTile({
    super.key,
    required this.postId,
    required this.title,
    required this.username,
    this.profilePicture,
    this.imageUrls,
    this.timestamp,
    required this.likeCount,
    required this.commentCount,
    this.onCommentTap,
  });

  @override
  ConsumerState<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends ConsumerState<MyListTile> {
  bool isLiked = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    try {
      final likeDoc = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.postId)
          .collection('Likes')
          .doc(currentUser.uid)
          .get();

      if (mounted) {
        setState(() {
          isLiked = likeDoc.exists;
        });
      }
    } catch (e) {
      print('Error checking like status: $e');
    }
  }

  Future<void> _toggleLike() async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    setState(() => isLoading = true);

    try {
      final postRef = FirebaseFirestore.instance.collection('Posts').doc(widget.postId);
      final likeRef = postRef.collection('Likes').doc(currentUser.uid);

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      final userData = userDoc.data() as Map<String, dynamic>?;
      final username = userData?['username'] ?? 'Anonymous';

      if (isLiked) {
        // Unlike
        await likeRef.delete();
        await postRef.update({
          'likeCount': FieldValue.increment(-1),
        });

        if (mounted) {
          setState(() => isLiked = false);
        }
      } else {
        // Like
        await likeRef.set({
          'userId': currentUser.uid,
          'userEmail': currentUser.email ?? '',
          'username': username,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await postRef.update({
          'likeCount': FieldValue.increment(1),
        });

        if (mounted) {
          setState(() => isLiked = true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showWhoLiked() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WhoLikedSheet(postId: widget.postId),
    );
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final postsService = ref.read(postsServiceProvider);
        await postsService.deletePost(widget.postId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editPost() async {
    final TextEditingController controller = TextEditingController(text: widget.title);

    final newMessage = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post cannot be empty'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, controller.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newMessage != null && newMessage != widget.title) {
      try {
        final postsService = ref.read(postsServiceProvider);
        await postsService.updatePost(widget.postId, newMessage);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final DateTime dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Posts').doc(widget.postId).get(),
      builder: (context, snapshot) {
        String? postOwnerId;
        if (snapshot.hasData && snapshot.data!.exists) {
          final postData = snapshot.data!.data() as Map<String, dynamic>;
          postOwnerId = postData['userId'];
        }

        final isOwnPost = currentUser?.uid == postOwnerId;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //header: User info + timestamp + menu
              Row(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    backgroundImage: widget.profilePicture != null
                        ? NetworkImage(widget.profilePicture!)
                        : null,
                    child: widget.profilePicture == null
                        ? Text(
                      widget.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),

                  const SizedBox(width: 12),

                  //username & timestamp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${widget.username}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        Text(
                          _formatTimestamp(widget.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //menu button (only for own posts)
                  if (isOwnPost)
                    PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              const Text('Edit'),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                                  () => _editPost(),
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red[400],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red[400]),
                              ),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                                  () => _deletePost(),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              //post content
              if (widget.title.isNotEmpty)
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),

              //images(if any)
              if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildImageGrid(context),
              ],

              const SizedBox(height: 12),

              //action buttons: Like, Comment, Share
              Row(
                children: [
                  // Like button
                  InkWell(
                    onTap: isLoading ? null : _toggleLike,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isLiked ? Colors.red : Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: widget.likeCount > 0 ? _showWhoLiked : null,
                            child: Text(
                              widget.likeCount.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: widget.likeCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  //comment button
                  InkWell(
                    onTap: widget.onCommentTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.commentCount.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  //share button
                  InkWell(
                    onTap: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share feature coming soon!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Icon(
                        Icons.share_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    if (widget.imageUrls == null || widget.imageUrls!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.imageUrls!.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.imageUrls![0],
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 50),
            ),
          ),
        ),
      );
    }

    // Multiple images grid
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.imageUrls!.length > 4 ? 4 : widget.imageUrls!.length,
      itemBuilder: (context, index) {
        if (index == 3 && widget.imageUrls!.length > 4) {
          //show "+X more" overlay on 4th image
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.imageUrls![index],
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '+${widget.imageUrls!.length - 3}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            widget.imageUrls![index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image),
              ),
            ),
          ),
        );
      },
    );
  }
}