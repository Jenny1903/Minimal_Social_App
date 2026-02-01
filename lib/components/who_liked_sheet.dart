import 'package:flutter/material.dart';

class WhoLikedSheet extends StatelessWidget {
  final List<String> likes;

  const WhoLikedSheet({super.key, required this.likes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //drag handle (visual indicator)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                'Liked by',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Divider(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          ),
          const SizedBox(height: 8),

          Flexible(
            child: likes.isEmpty
                ? _buildEmptyState(context)
                : _buildUserList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border,
            size: 60,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No likes yet',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  //user list- people who liked
  Widget _buildUserList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: likes.length,
      itemBuilder: (context, index) {
        final userEmail = likes[index];

        return Padding(
          padding: const EdgeInsets.all(40.0),
          child: Row(
            children: [
              //user avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

              const SizedBox(width: 12),

              //user email
              Expanded(
                child: Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),

              const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 18,
              ),
            ],
          ),
        );
      },
    );
  }
}
