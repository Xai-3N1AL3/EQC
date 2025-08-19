import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/reddit_meme.dart';

Future<List<RedditMeme>> fetchMemes({int limit = 15}) async {
  final subreddits = [
    'memes',
    'dankmemes',
    'wholesomememes',
    'ProgrammerHumor'
  ];
  final random = Random();
  final selectedSub = subreddits[random.nextInt(subreddits.length)];

  final response = await http
      .get(Uri.parse('https://meme-api.com/gimme/$selectedSub/$limit'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final memes = (data['memes'] as List)
        .map((json) => RedditMeme.fromJson(json))
        .toList();
    return memes;
  } else {
    throw Exception('Failed to load memes');
  }
}

String getTodayDate() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
