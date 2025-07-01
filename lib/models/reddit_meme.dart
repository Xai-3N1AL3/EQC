class RedditMeme {
  final String title;
  final String url;
  final String author;

  RedditMeme({required this.title, required this.url, required this.author});

  factory RedditMeme.fromJson(Map<String, dynamic> json) {
    return RedditMeme(
      title: json['title'],
      url: json['url'],
      author: json['author'],
    );
  }
}
