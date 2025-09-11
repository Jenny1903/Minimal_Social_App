import 'package:flutter/material.dart';
import '../models/posts.dart';
import 'post_widget.dart';

class FeedSection extends StatelessWidget {
  final List<Post> posts;

  const FeedSection({super.key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index){
          return PostWidget(post: posts[index]);

        },

    );
  }
}


