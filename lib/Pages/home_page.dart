import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/components/my_drawer.dart';
import 'package:social_app/components/my_list_tile.dart';
import 'package:social_app/components/my_post_button.dart';
import 'package:social_app/components/my_textfield.dart';
import 'package:social_app/providers/posts_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  //firestore access
  final TextEditingController newPostController = TextEditingController();

  @override
  void dispose() {
    newPostController.dispose();
    super.dispose();
  }


  //POST MESSAGE - Using Riverpod

  Future<void> postMessage() async {
    // Only post if there's something in the textfield
    if (newPostController.text.isEmpty) return;

    try {

      final postsService = ref.read(postsServiceProvider);

      //add the post
      await postsService.addPost(newPostController.text);

      //clear the textfield
      newPostController.clear();

      //show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created!'),
            duration: Duration(seconds: 1),
          ),
        );
      }

    } catch (e) {
      //handle errors
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

  @override
  Widget build(BuildContext context) {

    //WATCH the posts stream using Riverpod

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
          //lottie background for entire screen
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Lottie.asset(
                'assets/lottie/liking.json',
                fit: BoxFit.contain,
              ),
            ),
          ),

          //main content
          Column(
            children: [
              //post input
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
                child: Row(
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

                    //post button
                    PostButton(
                      onTap: postMessage,
                    )
                  ],
                ),
              ),

              const SizedBox(height: 10),

              //posts list

              Expanded(
                child: postsStream.when(

                  //DATA - We have posts
                  data: (snapshot) {
                    final posts = snapshot.docs;

                    //no posts - Show empty state
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

                    //display posts
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        // Get individual post
                        final post = posts[index];
                        final postData = post.data() as Map<String, dynamic>;

                        // Get data from each post
                        String postId = post.id;
                        String message = post['PostMessage'];
                        String userEmail = post['UserEmail'];
                        Timestamp timestamp = post['TimeStamp'];

                        List<dynamic> likes = postData.containsKey('Likes')
                            ? postData['Likes'] as List<dynamic>
                            : [];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: MyListTile(
                            postId: postId,
                            title: message,
                            subTitle: userEmail,
                            timestamp: timestamp,
                            likes: likes,
                          ),
                        );
                      },
                    );
                  },

                  //LOADING - Waiting for posts
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),

                  //ERROR - Something went wrong
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
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Retry by invalidating the provider
                            ref.invalidate(postsStreamProvider);
                          },
                          child: const Text('Retry'),
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
}