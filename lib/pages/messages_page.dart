// messages_page.dart
import 'package:flutter/material.dart';
import 'chat_detail_page.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> users = [
      {
        'name': 'Elon Musk',
        'avatarUrl': 'https://i.pravatar.cc/150?img=1',
        'messages': ['Wanna buy Twitter?', 'Let’s launch a rocket.']
      },
      {
        'name': 'Mark Zuck',
        'avatarUrl': 'https://i.pravatar.cc/150?img=2',
        'messages': ['Have you tried the metaverse?', 'Meta > Everything']
      },
      {
        'name': 'Satya',
        'avatarUrl': 'https://i.pravatar.cc/150?img=3',
        'messages': ['Azure all the way.', 'Join our next Build event!']
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user['avatarUrl']),
            ),
            title: Text(user['name']),
            subtitle: Text(user['messages'][0]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailPage(
                    userName: user['name'],
                    avatarUrl: user['avatarUrl'],
                    messages: List<String>.from(user['messages']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
