import 'package:flutter/material.dart';
import '../models/reddit_meme.dart';
import '../services/meme_api.dart';

class MemeFeedPage extends StatefulWidget {
  const MemeFeedPage({super.key});

  @override
  State<MemeFeedPage> createState() => _MemeFeedPageState();
}

class _MemeFeedPageState extends State<MemeFeedPage> {
  late Future<List<RedditMeme>> futureMemes;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  final Set<String> _likedMemes = {}; // Store liked meme titles or ids

  @override
  void initState() {
    super.initState();
    _fetchMemes();
  }

  void _fetchMemes() {
    setState(() {
      futureMemes = fetchMemes();
    });
  }

  Future<void> _manualRefresh() async {
    _fetchMemes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meme Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _manualRefresh,
          ),
        ],
      ),
      body: FutureBuilder<List<RedditMeme>>(
        future: futureMemes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No memes found.'));
          }

          final memes = snapshot.data!;

          return RefreshIndicator(
            key: _refreshKey,
            onRefresh: _manualRefresh,
            child: ListView.builder(
              key: const PageStorageKey('memeFeed'),
              itemCount: memes.length,
              itemBuilder: (context, index) {
                final meme = memes[index];
                final isLiked = _likedMemes.contains(meme.title);

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            meme.author.isNotEmpty ? meme.author[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(meme.author),
                        subtitle: Text(meme.title),
                        trailing: IconButton(
                          icon: Text(
                            isLiked ? '😂' : '😐',
                            style: const TextStyle(fontSize: 24),
                          ),
                          onPressed: () {
                            setState(() {
                              if (isLiked) {
                                _likedMemes.remove(meme.title);
                              } else {
                                _likedMemes.add(meme.title);
                              }
                            });
                          },
                        ),
                      ),
                      if (meme.url.endsWith(".jpg") || meme.url.endsWith(".jpeg") || meme.url.endsWith(".png"))
                        Image.network(
                          meme.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
