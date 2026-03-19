import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/components/my_drawer.dart';
import 'package:social_app/components/my_list_tile.dart';
import 'package:social_app/components/my_post_button.dart';
import 'package:social_app/components/my_textfield.dart';
import 'package:social_app/providers/posts_provider.dart';
import 'package:social_app/services/image_service.dart';
import 'package:social_app/services/comments_service.dart';
import 'package:social_app/providers/auth_provider.dart';
import 'package:social_app/components/clickable_username.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController newPostController = TextEditingController();
  final ImageService _imageService = ImageService();

  //selected images for the post
  List<File> selectedImages = [];

  //loading state
  bool isPosting = false;

  @override
  void dispose() {
    newPostController.dispose();
    super.dispose();
  }

  //pick images for post
  Future<void> pickImages() async {
    try {
      final images = await _imageService.pickPostImages();

      if (images.isNotEmpty) {
        setState(() {
          selectedImages = images;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${images.length} image(s) selected'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //post message with images
  Future<void> postMessage() async {
    // Check if there's text or images
    if (newPostController.text.isEmpty && selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something or add images'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isPosting = true);

    try {
      final postsService = ref.read(postsServiceProvider);

      List<String> imageUrls = [];

      //step:1 ~ Upload images if any selected
      if (selectedImages.isNotEmpty) {
        //generate temporary post ID for image naming
        final tempPostId = DateTime.now().millisecondsSinceEpoch.toString();

        print('Uploading ${selectedImages.length} images...');
        imageUrls = await _imageService.uploadPostImages(
          selectedImages,
          tempPostId,
        );
        print('Images uploaded: $imageUrls');
      }
      //step:2 ~ create post with image URLs
      print('Creating post with ${imageUrls.length} images');
      print('Image URLs: $imageUrls');

      await postsService.addPost(
        newPostController.text.trim(),
        imageUrls: imageUrls.isEmpty ? null : imageUrls,
      );

      print('Post created successfully');

      //step:3 ~ clear everything
      newPostController.clear();
      setState(() {
        selectedImages = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created!'),
            duration: Duration(seconds: 2),
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
    } finally {
      if (mounted) {
        setState(() => isPosting = false);
      }
    }
  }

  //remove selected images
  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  //show comments bottom sheet
  Future<void> _showCommentsBottomSheet(
      BuildContext context,
      String postId,
      String postMessage,
      String username,
      ) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(

        builder: (context, ref, child) {
          final TextEditingController commentController = TextEditingController();

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  //post preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              child: Text(
                                username[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '@$username',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                        if (postMessage.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            postMessage,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  //comments header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        const Spacer(),
                        Consumer(
                          builder: (context, ref, child) {
                            final commentsAsync = ref.watch(commentsStreamProvider(postId));
                            return commentsAsync.when(
                              data: (snapshot) => Text(
                                '${snapshot.docs.length}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  //comments list
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final commentsAsync = ref.watch(commentsStreamProvider(postId));

                        return commentsAsync.when(
                          data: (snapshot) {
                            if (snapshot.docs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No comments yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Be the first to comment!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: snapshot.docs.length,
                              itemBuilder: (context, index) {
                                final comment = snapshot.docs[index];
                                final commentData = comment.data() as Map<String, dynamic>;
                                final currentUser = ref.watch(authStateProvider).value;
                                final isOwnComment = currentUser?.uid == commentData['userId'];

                                return _buildCommentItem(
                                  context,
                                  ref,
                                  commentData,
                                  comment.id,
                                  postId,
                                  isOwnComment,
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, _) => Center(
                            child: Text(
                              'Error loading comments',
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        );
                      },
                    ),
                  ),


                  Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            print('Send button pressed!');
                            print('Comment text: "${commentController.text}"');

                            if (commentController.text.trim().isEmpty) {
                              print('Comment is empty');
                              return;
                            }

                            try {
                              print('Getting commentsService...');
                              final commentsService = ref.read(commentsServiceProvider);

                              print('Adding comment to postId: $postId');
                              await commentsService.addComment(
                                postId,
                                commentController.text.trim(),
                              );

                              print('Comment added successfully!');
                              commentController.clear();

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Comment added!'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            } catch (e) {
                              print('Error adding comment: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          icon: Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentItem(
      BuildContext context,
      WidgetRef ref,
      Map<String, dynamic> commentData,
      String commentId,
      String postId,
      bool isOwnComment,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: ClickableUsernameStyled(
                  username: commentData['username'] ?? 'Anonymous',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${commentData['username'] ?? 'Anonymous'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    Text(
                      _formatTimestamp(commentData['timestamp']),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwnComment)
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red[400],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.red[400]),
                          ),
                        ],
                      ),
                      onTap: () async {
                        try {
                          final commentsService = ref.read(commentsServiceProvider);
                          await commentsService.deleteComment(postId, commentId);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Comment deleted')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            commentData['text'] ?? '',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    final DateTime dateTime = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.parse(timestamp.toString());

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
    final postsStream = ref.watch(postsStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text("F E L L O"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),

      drawer: const MyDrawer(),

      body: Stack(
        children: [
          //lottie background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Lottie.asset(
                'assets/lottie/liking.json',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              //post input section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    //input row
                    Row(
                      children: [
                        //user avatar
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.inversePrimary,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 12),

                        //textfield
                        Expanded(
                          child: MyTextfield(
                            hintText: "Say something",
                            obscureText: false,
                            controller: newPostController,
                          ),
                        ),

                        const SizedBox(width: 8),

                        //image picker button
                        IconButton(
                          onPressed: isPosting ? null : pickImages,
                          icon: Icon(
                            Icons.image_outlined,
                            color: selectedImages.isNotEmpty
                                ? Colors.blue
                                : Theme.of(context).colorScheme.secondary,
                          ),
                          tooltip: 'Add images',
                        ),

                        //post button
                        PostButton(
                          onTap: isPosting ? null : postMessage,
                        ),
                      ],
                    ),

                    //selected images preview
                    if (selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildSelectedImagesPreview(),
                    ],

                    //loading indicator
                    if (isPosting) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Uploading...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 10),

              //post list
              Expanded(
                child: postsStream.when(
                  data: (snapshot) {
                    final posts = snapshot.docs;

                    if (posts.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          // Refresh by invalidating the provider
                          ref.invalidate(postsStreamProvider);
                          await Future.delayed(const Duration(milliseconds: 500));
                        },
                        child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                        SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                "No posts yet",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Be the first to share something!",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                        ],
                      ),
                    );
                    }

                    return RefreshIndicator(
                    onRefresh: () async {
                    // Refresh by invalidating the provider
                    ref.invalidate(postsStreamProvider);
                    await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: posts.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                    final post = posts[index];
                    final postData = post.data() as Map<String, dynamic>;

                    String postId = post.id;
                    String message = postData['PostMessage'] ?? '';
                    String username = postData['username'] ?? 'Anonymous';
                    Timestamp? timestamp = postData['TimeStamp'];
                    int likeCount = postData['likeCount'] ?? 0;
                    int commentCount = postData['commentCount'] ?? 0;

                    //get images and profile picture
                    List<String>? imageUrls = postData['images'] != null
                    ? List<String>.from(postData['images'])
                        : null;
                    String? profilePicture = postData['profilePicture'];

                    return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: MyListTile(
                    postId: postId,
                    title: message,
                    username: username,
                    profilePicture: profilePicture,
                    imageUrls: imageUrls,
                    timestamp: timestamp,
                    likeCount: likeCount,
                    commentCount: commentCount,
                    onCommentTap: () {
                    _showCommentsBottomSheet(
                    context,
                    postId,
                    message,
                    username,
                    );
                    },
                    ),
                    );
                    },
                    ),
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading posts',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //build selected image preview
  Widget _buildSelectedImagesPreview() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                //Image preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    selectedImages[index],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),

                //remove button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}