import 'package:flutter/material.dart';
import '../models/reddit_meme.dart';
import '../services/meme_api.dart';

class MemeFeedPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const MemeFeedPage({super.key, required this.toggleTheme});

  @override
  State<MemeFeedPage> createState() => MemeFeedPageState();
}

class MemeFeedPageState extends State<MemeFeedPage>
    with TickerProviderStateMixin {
  final List<RedditMeme> _memes = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final Set<String> _likedMemes = {};
  final Map<int, AnimationController> _animationControllers = {};
  final Map<int, Animation<double>> _animations = {};
  final Map<int, AnimationController> _emojiControllers = {};
  final Map<int, Animation<double>> _emojiAnimations = {};

  bool _isLoading = false;
  bool _hasReachedEnd = false;
  String _currentDate = '';
  int _currentPage = 0;
  static const int _memesPerPage = 10;
  static const int _maxMemesPerDay = 50; // Daily limit

  @override
  void initState() {
    super.initState();
    _currentDate = getTodayDate();
    _loadInitialMemes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    for (var controller in _emojiControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMemes();
    }
  }

  Future<void> _loadInitialMemes() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasReachedEnd = false;
      _currentPage = 0;
    });

    try {
      final newMemes = await fetchMemes(limit: _memesPerPage);
      setState(() {
        _memes.clear();
        _memes.addAll(newMemes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMemes() async {
    if (_isLoading || _hasReachedEnd) return;

    // Check if we've reached the daily limit
    if (_memes.length >= _maxMemesPerDay) {
      setState(() {
        _hasReachedEnd = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newMemes = await fetchMemes(limit: _memesPerPage);

      if (newMemes.isEmpty) {
        setState(() {
          _hasReachedEnd = true;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _memes.addAll(newMemes);
        _currentPage++;
        _isLoading = false;

        // Check if we've reached the daily limit after adding new memes
        if (_memes.length >= _maxMemesPerDay) {
          _hasReachedEnd = true;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> manualRefresh() async {
    _loadInitialMemes();
  }

  void _initializeAnimation(int index) {
    if (!_animationControllers.containsKey(index)) {
      _animationControllers[index] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _animations[index] = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationControllers[index]!,
        curve: Curves.easeInOut,
      ));
    }
  }

  void _initializeEmojiAnimation(int index) {
    if (!_emojiControllers.containsKey(index)) {
      _emojiControllers[index] = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      _emojiAnimations[index] = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _emojiControllers[index]!,
        curve: Curves.easeInOut,
      ));

      // Start the emoji animation
      _emojiControllers[index]!.repeat(reverse: true);
    }
  }

  Widget _buildEndMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            size: 48,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            "That's all for today! 🎉",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "You've seen $_maxMemesPerDay memes today!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Come back tomorrow for more fresh memes!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "Date: $_currentDate",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900,
              Colors.indigo.shade800,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _build3DAppBar(),
              Expanded(
                child: RefreshIndicator(
                  key: _refreshKey,
                  onRefresh: manualRefresh,
                  child: _memes.isEmpty && !_isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          key: const PageStorageKey('memeFeed'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          itemCount: _memes.length +
                              (_hasReachedEnd ? 1 : 0) +
                              (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show end message
                            if (_hasReachedEnd && index == _memes.length) {
                              return _build3DEndMessage();
                            }

                            // Show loading indicator
                            if (_isLoading && index == _memes.length) {
                              return _build3DLoadingIndicator();
                            }

                            final meme = _memes[index];
                            final isLiked = _likedMemes.contains(meme.title);
                            _initializeAnimation(index);
                            _initializeEmojiAnimation(index);

                            return _build3DMemeCard(meme, index, isLiked);
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform(
            transform: Matrix4.identity()..setEntry(3, 2, 0.001),
            child: const Text(
              'Meme Feed',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Transform(
            transform: Matrix4.identity()..setEntry(3, 2, 0.001),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.brightness_6, color: Colors.white),
                onPressed: widget.toggleTheme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DMemeCard(RedditMeme meme, int index, bool isLiked) {
    return AnimatedBuilder(
      animation: _animations[index]!,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_animations[index]!.value * 0.1)
            ..rotateY(_animations[index]!.value * 0.05)
            ..translate(
              0.0,
              -_animations[index]!.value * 5.0,
            )
            ..scale(1.0 + _animations[index]!.value * 0.02),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.15),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15.0,
                  offset: const Offset(0, 5),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  _animationControllers[index]!.forward().then((_) {
                    _animationControllers[index]!.reverse();
                  });
                },
                onHover: (isHovered) {
                  if (isHovered) {
                    _animationControllers[index]!.forward();
                  } else {
                    _animationControllers[index]!.reverse();
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _build3DMemeHeader(meme, index, isLiked),
                    if (meme.url.endsWith(".jpg") ||
                        meme.url.endsWith(".jpeg") ||
                        meme.url.endsWith(".png"))
                      _build3DMemeImage(meme, index),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _build3DMemeHeader(RedditMeme meme, int index, bool isLiked) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(_animations[index]!.value * 0.02),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..scale(1.0 + _animations[index]!.value * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade500,
                      Colors.blue.shade600,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    meme.author.isNotEmpty ? meme.author[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meme.author,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 1),
                          blurRadius: 2.0,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meme.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _emojiAnimations[index]!,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..scale(1.0 +
                        _animations[index]!.value * 0.1 +
                        _emojiAnimations[index]!.value * 0.2)
                    ..rotateZ(_emojiAnimations[index]!.value * 0.1),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isLiked) {
                            _likedMemes.remove(meme.title);
                          } else {
                            _likedMemes.add(meme.title);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isLiked
                              ? Colors.red.withOpacity(0.3)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          isLiked ? '😂' : '😐',
                          style: TextStyle(
                            fontSize: 20 + _emojiAnimations[index]!.value * 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DMemeImage(RedditMeme meme, int index) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_animations[index]!.value * 0.02)
        ..rotateY(_animations[index]!.value * 0.01),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            meme.url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _build3DLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text(
              'Loading more memes...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DEndMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            "That's all for today! 🎉",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 2.0,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "You've seen $_maxMemesPerDay memes today!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Come back tomorrow for more fresh memes!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Date: $_currentDate",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
