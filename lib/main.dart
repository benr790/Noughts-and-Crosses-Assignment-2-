import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ------------------------------------------------------------
// 1. ROOT APP WIDGET — controls theme + loads HomeScreen
// ------------------------------------------------------------
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noughts and Crosses',
      debugShowCheckedModeBanner: false,

      // Light theme
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),

      // Dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.teal,
        ),
      ),

      themeMode: _themeMode,

      home: HomeScreen(
        themeMode: _themeMode,
        onThemeChanged: _setThemeMode,
      ),
    );
  }
}

// ------------------------------------------------------------
// 2. HOME SCREEN — menu with 3 buttons
// ------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noughts and Crosses')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                child: const Text('Single Player'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GameScreen(isSinglePlayer: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Multiplayer'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GameScreen(isSinglePlayer: false),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Options'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OptionsScreen(
                        themeMode: themeMode,
                        onThemeChanged: onThemeChanged,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// 3. OPTIONS SCREEN — toggle dark/light mode
// ------------------------------------------------------------
class OptionsScreen extends StatelessWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) onThemeChanged;

  const OptionsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDark,
            onChanged: (value) {
              onThemeChanged(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// 4. GAME SCREEN — single + multiplayer logic
// ------------------------------------------------------------
class GameScreen extends StatefulWidget {
  final bool isSinglePlayer;

  const GameScreen({super.key, required this.isSinglePlayer});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String _statusText = '';
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  // Reset board + status
  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _gameOver = false;

      _statusText = widget.isSinglePlayer
          ? 'Your turn (X)'
          : 'Player X\'s turn';
    });
  }

  // Handle tap on a square
  void _handleTap(int index) {
    if (_gameOver || _board[index].isNotEmpty) return;

    _makeMove(index, _currentPlayer);

    if (_gameOver) return;

    if (widget.isSinglePlayer && _currentPlayer == 'O') {
      _makeAIMove();
    }
  }

  // Make a move for X or O
  void _makeMove(int index, String player) {
    if (_board[index].isNotEmpty || _gameOver) return;

    setState(() {
      _board[index] = player;
    });

    String? winner = _checkWinner();
    if (winner != null) {
      setState(() {
        _statusText =
            winner == 'Draw' ? 'It\'s a draw!' : 'Player $winner wins!';
        _gameOver = true;
      });
      return;
    }

    setState(() {
      _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';

      if (widget.isSinglePlayer) {
        _statusText = _currentPlayer == 'X'
            ? 'Your turn (X)'
            : 'AI\'s turn (O)';
      } else {
        _statusText = 'Player $_currentPlayer\'s turn';
      }
    });
  }

  // Simple random AI
  void _makeAIMove() async {
    await Future.delayed(const Duration(milliseconds: 400));

    List<int> empty = [];
    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) empty.add(i);
    }

    if (empty.isEmpty) return;

    int move = empty[Random().nextInt(empty.length)];
    _makeMove(move, 'O');
  }

  // Check winner or draw
  String? _checkWinner() {
    List<List<int>> lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var line in lines) {
      String a = _board[line[0]];
      String b = _board[line[1]];
      String c = _board[line[2]];

      if (a.isNotEmpty && a == b && b == c) return a;
    }

    if (!_board.contains('')) return 'Draw';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    String mode = widget.isSinglePlayer ? 'Single Player' : 'Multiplayer';

    return Scaffold(
      appBar: AppBar(
        title: Text('Game - $mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(_statusText, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),

          // GAME GRID
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _handleTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _board[index],
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,

                              // COLOURED X AND O
                              color: _board[index] == 'X'
                                  ? Colors.blue
                                  : _board[index] == 'O'
                                      ? Colors.red
                                      : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _resetGame,
            child: const Text('Play Again'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

