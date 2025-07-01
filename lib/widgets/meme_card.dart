import 'package:flutter/material.dart';

class MemeCard extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final bool isLiked;
  final VoidCallback onLike;

  const MemeCard({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.isLiked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                author.isNotEmpty ? author[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(author),
            subtitle: Text(title),
            trailing: IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : null,
              ),
              onPressed: onLike,
            ),
          ),
          if (imageUrl.endsWith(".jpg") ||
              imageUrl.endsWith(".jpeg") ||
              imageUrl.endsWith(".png"))
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
