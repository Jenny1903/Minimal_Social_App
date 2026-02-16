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
      await postsService.addPost(
        newPostController.text.trim(),
        imageUrls: imageUrls.isEmpty ? null : imageUrls,
      );

      //step:3 ~ clear everything
      newPostController.clear();
      setState(() {
        selectedImages = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created!'),
            duration: Duration(seconds: 1),
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
                      return Center(
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
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final postData = post.data() as Map<String, dynamic>;

                        String postId = post.id;
                        String message = postData['PostMessage'] ?? '';
                        String username = postData['username'] ?? 'Anonymous';
                        Timestamp? timestamp = postData['TimeStamp'];
                        int likeCount = postData['likeCount'] ?? 0;

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
                          ),
                        );
                      },
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
                // Image preview
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
