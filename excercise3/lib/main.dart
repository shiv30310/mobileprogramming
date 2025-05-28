import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const BucketBallGame());
}

class BucketBallGame extends StatelessWidget {
  const BucketBallGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bucket Ball Collector',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum GameLevel {
  easy,
  medium,
  hard,
  expert,
  nightmare
}

class LevelConfig {
  final String name;
  final int levelNumber;
  final int ballSpawnInterval;
  final double minBallSpeed;
  final double maxBallSpeed;
  final int pointsPerBall;
  final Color themeColor;
  final String emoji;

  const LevelConfig({
    required this.name,
    required this.levelNumber,
    required this.ballSpawnInterval,
    required this.minBallSpeed,
    required this.maxBallSpeed,
    required this.pointsPerBall,
    required this.themeColor,
    required this.emoji,
  });
}

class Ball {
  double x;
  double y;
  double speed;
  Color color;
  double size;

  Ball({
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
    required this.size,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final List<Ball> _balls = [];
  double _bucketX = 150;
  double _bucketY = 500;
  static const double _bucketWidth = 80;
  static const double _bucketHeight = 40;
  int _score = 0;
  int _lives = 3;
  bool _isGameRunning = false;
  Timer? _gameTimer;
  Timer? _ballSpawnTimer;
  late AnimationController _bucketController;
  late Animation<double> _bucketAnimation;
  GameLevel _currentLevel = GameLevel.easy;

  final Random _random = Random();
  static const List<Color> _ballColors = [
    Color(0xFFFF6B9D),
    Color(0xFF95E1D3),
    Color(0xFFFCE38A),
    Color(0xFFB8B5FF),
    Color(0xFFFFB5B5),
    Color(0xFFA8E6CF),
    Color(0xFFDDA0DD),
    Color(0xFFFFE4B5),
  ];

  static const Map<GameLevel, LevelConfig> _levelConfigs = {
    GameLevel.easy: LevelConfig(
      name: 'Dreamy Easy',
      levelNumber: 1,
      ballSpawnInterval: 1800,
      minBallSpeed: 1.5,
      maxBallSpeed: 3.0,
      pointsPerBall: 10,
      themeColor: Color(0xFF95E1D3),
      emoji: '🌸',
    ),
    GameLevel.medium: LevelConfig(
      name: 'Sweet Medium',
      levelNumber: 2,
      ballSpawnInterval: 1400,
      minBallSpeed: 2.0,
      maxBallSpeed: 4.0,
      pointsPerBall: 15,
      themeColor: Color(0xFFFFB5B5),
      emoji: '🌺',
    ),
    GameLevel.hard: LevelConfig(
      name: 'Intense Hard',
      levelNumber: 3,
      ballSpawnInterval: 1000,
      minBallSpeed: 2.5,
      maxBallSpeed: 5.0,
      pointsPerBall: 20,
      themeColor: Color(0xFFFF6B9D),
      emoji: '🔥',
    ),
    GameLevel.expert: LevelConfig(
      name: 'Expert Rush',
      levelNumber: 4,
      ballSpawnInterval: 700,
      minBallSpeed: 3.0,
      maxBallSpeed: 6.0,
      pointsPerBall: 25,
      themeColor: Color(0xFFDDA0DD),
      emoji: '⚡',
    ),
    GameLevel.nightmare: LevelConfig(
      name: 'Nightmare Mode',
      levelNumber: 5,
      ballSpawnInterval: 500,
      minBallSpeed: 4.0,
      maxBallSpeed: 8.0,
      pointsPerBall: 30,
      themeColor: Color(0xFFB8B5FF),
      emoji: '💀',
    ),
  };

  static const int _gameLoopInterval = 16;
  static const double _minBallSize = 20;
  static const double _maxBallSize = 35;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _bucketController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bucketAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bucketController, curve: Curves.elasticOut),
    );
  }

  LevelConfig get _currentLevelConfig => _levelConfigs[_currentLevel]!;

  void startGame() {
    setState(() {
      _isGameRunning = true;
      _score = 0;
      _lives = 3;
      _balls.clear();
      _bucketX = 150;
    });

    _startGameLoop();
    _startBallSpawning();
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(
      const Duration(milliseconds: _gameLoopInterval),
          (timer) {
        if (!_isGameRunning) {
          timer.cancel();
          return;
        }
        _updateGame();
      },
    );
  }

  void _startBallSpawning() {
    _ballSpawnTimer = Timer.periodic(
      Duration(milliseconds: _currentLevelConfig.ballSpawnInterval),
          (timer) {
        if (!_isGameRunning) {
          timer.cancel();
          return;
        }
        _spawnBall();
      },
    );
  }

  void _spawnBall() {
    if (!mounted) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final ballSize = _minBallSize + _random.nextDouble() * (_maxBallSize - _minBallSize);

    setState(() {
      _balls.add(Ball(
        x: _random.nextDouble() * (screenWidth - ballSize),
        y: -ballSize,
        speed: _currentLevelConfig.minBallSpeed +
            _random.nextDouble() * (_currentLevelConfig.maxBallSpeed - _currentLevelConfig.minBallSpeed),
        color: _ballColors[_random.nextInt(_ballColors.length)],
        size: ballSize,
      ));
    });
  }

  void _updateGame() {
    if (!mounted) return;

    setState(() {
      final screenHeight = MediaQuery.of(context).size.height;

      for (int i = _balls.length - 1; i >= 0; i--) {
        _balls[i].y += _balls[i].speed;

        if (_checkBallCaught(i)) {
          _handleBallCaught(i);
          continue;
        }

        if (_balls[i].y > screenHeight) {
          _handleBallMissed(i);
        }
      }
    });
  }

  bool _checkBallCaught(int ballIndex) {
    final ball = _balls[ballIndex];
    return ball.y + ball.size >= _bucketY &&
        ball.y <= _bucketY + _bucketHeight &&
        ball.x + ball.size >= _bucketX &&
        ball.x <= _bucketX + _bucketWidth;
  }

  void _handleBallCaught(int ballIndex) {
    _score += _currentLevelConfig.pointsPerBall;
    _balls.removeAt(ballIndex);
    _playBucketAnimation();
  }

  void _handleBallMissed(int ballIndex) {
    _balls.removeAt(ballIndex);
    _lives--;
    if (_lives <= 0) {
      _gameOver();
    }
  }

  void _playBucketAnimation() {
    _bucketController.forward().then((_) {
      if (mounted) {
        _bucketController.reverse();
      }
    });
  }

  void _gameOver() {
    setState(() {
      _isGameRunning = false;
    });
    _cancelTimers();

    if (!mounted) return;

    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_currentLevelConfig.themeColor, _currentLevelConfig.themeColor.withOpacity(0.7)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _currentLevelConfig.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Dream Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF6B5B95),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Level ${_currentLevelConfig.levelNumber}: ${_currentLevelConfig.name}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: _currentLevelConfig.themeColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_currentLevelConfig.themeColor, _currentLevelConfig.themeColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Final Score: $_score',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF95E1D3).withOpacity(0.8),
                        const Color(0xFFA8E6CF).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      startGame();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text(
                      'Dream Again ✨',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Your Dream Level',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF6B5B95),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                ...GameLevel.values.map((level) {
                  final config = _levelConfigs[level]!;
                  final isSelected = level == _currentLevel;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                        colors: [config.themeColor, config.themeColor.withOpacity(0.7)],
                      )
                          : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? config.themeColor : Colors.grey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _currentLevel = level;
                        });
                        Navigator.of(context).pop();
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.2) : config.themeColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          config.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        'Level ${config.levelNumber}: ${config.name}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF6B5B95),
                        ),
                      ),
                      subtitle: Text(
                        '${config.pointsPerBall} pts/ball • Speed: ${config.minBallSpeed.toStringAsFixed(1)}-${config.maxBallSpeed.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF95E1D3), Color(0xFFA8E6CF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _moveBucket(double newX) {
    if (!mounted || !_isGameRunning) return;

    setState(() {
      final screenWidth = MediaQuery.of(context).size.width;
      _bucketX = newX.clamp(0, screenWidth - _bucketWidth);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    _moveBucket(localPosition.dx - _bucketWidth / 2);
  }

  void _onTapDown(TapDownDetails details) {
    if (!_isGameRunning) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    _moveBucket(localPosition.dx - _bucketWidth / 2);
  }

  void _cancelTimers() {
    _gameTimer?.cancel();
    _ballSpawnTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    _bucketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    _bucketY = screenHeight - 150;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Dreamy Ball Catcher',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _currentLevelConfig.themeColor.withOpacity(0.8),
                  _currentLevelConfig.themeColor.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _showSettingsDialog,
              icon: const Icon(Icons.settings, color: Colors.white),
              tooltip: 'Game Settings',
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onTapDown: _onTapDown,
        child: Stack(
          children: [
            _buildBackground(),
            if (_isGameRunning) ..._buildGameElements(),
            if (_isGameRunning) _buildScoreDisplay(),
            if (!_isGameRunning) _buildStartScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE5F1),
            Color(0xFFE8F8F5),
            Color(0xFFF0F8FF),
            Color(0xFFFFF0F5),
            Color(0xFFE8F5E8),
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.3, -0.5),
            radius: 1.2,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGameElements() {
    return [
      ..._buildBalls(),
      _buildBucket(),
      _buildGameInstructions(),
    ];
  }

  List<Widget> _buildBalls() {
    return _balls.map((ball) => Positioned(
      left: ball.x,
      top: ball.y,
      child: Container(
        width: ball.size,
        height: ball.size,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              ball.color,
              ball.color.withOpacity(0.7),
            ],
            stops: const [0.3, 1.0],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ball.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
      ),
    )).toList();
  }

  Widget _buildBucket() {
    return Positioned(
      left: _bucketX,
      top: _bucketY,
      child: AnimatedBuilder(
        animation: _bucketAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bucketAnimation.value,
            child: Container(
              width: _bucketWidth,
              height: _bucketHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _currentLevelConfig.themeColor,
                    _currentLevelConfig.themeColor.withOpacity(0.8),
                    _currentLevelConfig.themeColor.withOpacity(0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                border: Border.all(
                  color: _currentLevelConfig.themeColor.withOpacity(0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _currentLevelConfig.themeColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7),
                    blurRadius: 4,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameInstructions() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.7),
              Colors.white.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'Level ${_currentLevelConfig.levelNumber} • Tap or drag to move • ${_currentLevelConfig.name} ${_currentLevelConfig.emoji}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B5B95),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Positioned(
      top: 100,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.8),
              Colors.white.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.7),
              blurRadius: 10,
              offset: const Offset(-3, -3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_currentLevelConfig.themeColor, _currentLevelConfig.themeColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Level ${_currentLevelConfig.levelNumber}: $_score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_currentLevelConfig.name} ${_currentLevelConfig.emoji}',
              style: TextStyle(
                fontSize: 12,
                color: _currentLevelConfig.themeColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  ' ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B5B95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ...List.generate(
                  _lives,
                      (index) => Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFFFF6B9D),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.7),
              Colors.white.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 20,
              offset: const Offset(-5, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_currentLevelConfig.themeColor, _currentLevelConfig.themeColor.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _currentLevelConfig.themeColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                _currentLevelConfig.emoji,
                style: const TextStyle(fontSize: 60),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Dreamy Ball Catcher',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Color(0xFF6B5B95),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_currentLevelConfig.themeColor.withOpacity(0.2), _currentLevelConfig.themeColor.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _currentLevelConfig.themeColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Level ${_currentLevelConfig.levelNumber}: ${_currentLevelConfig.name} ${_currentLevelConfig.emoji}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _currentLevelConfig.themeColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Catch the magical floating balls!\nTap or drag to move your basket.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_currentLevelConfig.themeColor, _currentLevelConfig.themeColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: _currentLevelConfig.themeColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'START DREAMING ✨',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}