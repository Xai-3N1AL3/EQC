// messages_page.dart
import 'package:flutter/material.dart';
import '../models/message.dart';
import 'chat_detail_page.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> users = [
      {
        'name': 'Elon Musk',
        'avatarUrl': 'https://i.pravatar.cc/150?img=1',
        'messages': <Message>[],
      },
      {
        'name': 'Mark Zuck',
        'avatarUrl': 'https://i.pravatar.cc/150?img=2',
        'messages': <Message>[],
      },
      {
        'name': 'Satya Nadella',
        'avatarUrl': 'https://i.pravatar.cc/150?img=3',
        'messages': <Message>[],
      },
      {
        'name': 'Tim Cook',
        'avatarUrl': 'https://i.pravatar.cc/150?img=4',
        'messages': <Message>[],
      },
      {
        'name': 'Sundar Pichai',
        'avatarUrl': 'https://i.pravatar.cc/150?img=5',
        'messages': <Message>[],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final messages = user['messages'] as List<Message>;
          final hasMessages = messages.isNotEmpty;
          final lastMessage = hasMessages ? messages.last : null;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user['avatarUrl']),
                radius: 25,
              ),
              title: Text(
                user['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
              subtitle: Text(
                hasMessages ? lastMessage!.text : 'Start a conversation',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      hasMessages ? Colors.grey.shade600 : Colors.blue.shade600,
                  fontWeight: hasMessages ? FontWeight.normal : FontWeight.w500,
                  fontStyle: hasMessages ? FontStyle.normal : FontStyle.italic,
                ),
              ),
              trailing: hasMessages
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(lastMessage!.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatDetailPage(
                      userName: user['name'],
                      avatarUrl: user['avatarUrl'],
                      messages: messages,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
