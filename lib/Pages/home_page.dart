import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/components/my_drawer.dart';
import 'package:social_app/components/my_list_tile.dart';
import 'package:social_app/components/my_post_button.dart';
import 'package:social_app/components/my_textfield.dart';
import 'package:social_app/database/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore access
  final FirestoreDatabase database = FirestoreDatabase();

  //text controller
  final TextEditingController newPostController = TextEditingController();

  //post message
  void postMessage() {
    //only post message if there is something in the textfield
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }

    //clear the controller
    newPostController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text("F E L L O"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),

      //drawer
      drawer: const MyDrawer(),

      body: Stack(
        children: [
          // Lottie background for entire screen
          Positioned.fill(
            child: Opacity(
              opacity: 0.6, // Adjust opacity as needed
              child: Lottie.asset(
                'assets/lottie/liking.json',
                fit: BoxFit.contain,
              ),
            ),
          ),

          //main content on top
          Column(
            children: [
              //pOST INPUT SECTION
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
                    // User avatar
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
              Expanded(
                child: StreamBuilder(
                  stream: database.getPostsStream(),
                  builder: (context, snapshot) {
                    // Show loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      );
                    }

                    // Get all posts
                    final posts = snapshot.data!.docs;

                    // No data - Show beautiful empty state
                    if (snapshot.data == null || posts.isEmpty) {
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

                    //return posts list
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        //get individual post
                        final post = posts[index];

                        //get data from each post
                        String message = post['PostMessage'];
                        String userEmail = post['UserEmail'];
                        Timestamp timestamp = post['TimeStamp'];

                        //return as a card with spacing
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: MyListTile(
                            title: message,
                            subTitle: userEmail,
                            timestamp: timestamp,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}