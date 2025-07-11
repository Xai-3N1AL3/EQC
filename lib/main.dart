import 'package:flutter/material.dart';
import 'pages/meme_feed_page.dart';
import 'pages/profile_page.dart';
import 'pages/messages_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  final GlobalKey<MemeFeedPageState> _feedKey = GlobalKey<MemeFeedPageState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EQC Meme-App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: HomePage(toggleTheme: _toggleTheme, feedKey: _feedKey),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final GlobalKey<MemeFeedPageState> feedKey;

  const HomePage({super.key, required this.toggleTheme, required this.feedKey});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MemeFeedPage(key: widget.feedKey, toggleTheme: widget.toggleTheme),
      const MessagesPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex == index && index == 0) {
            widget.feedKey.currentState?.manualRefresh();
          }
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
